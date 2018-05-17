#!/bin/bash

set -e

# Load environment variables set by Docker
if [ -e /opt/letsencrypt/etc/global.env ]; then
	. /opt/letsencrypt/etc/global.env
fi

mkdir -p /opt/www

# Certificates are separated by semi-colon (;) or newline. Domains on each
# certificate are separated by comma (,).
CERTS=(${DOMAINS//;/ })

echo "Waiting for nginx & haproxy to be ready..."
sleep 10;
echo "Done!"
mkdir -p /opt/www
mkdir -p /etc/letsencrypt/live
mkdir -p /certs

# Create or renew certificates.
for DOMAINS in "${CERTS[@]}"; do
    ls -lah /opt/www
	if certbot certonly \
			--agree-tos \
			--domains "$DOMAINS" \
			--email "$EMAIL" \
			--expand \
			--noninteractive \
			--webroot \
			--webroot-path /opt/www \
			$OPTIONS; then # || true  # Don't exit if a single certificate fails
		if [[ -z "$DEFAULT" ]]; then
			DEFAULT="$(echo "$DOMAINS" | cut -d',' -f1)"
			echo "Found first successful certificate to use as default: $DEFAULT"
		fi
	fi
done

# Combine private key and full certificate chain for HAproxy.

cd /etc/letsencrypt/live
for domain in *; do
	cat "$domain/privkey.pem" "$domain/fullchain.pem" > "/certs/$domain.pem"
	if [[ "$domain" = "$DEFAULT" ]]; then
		echo "Saving default certificate ($domain) as '_default.pem'."
		cp "/certs/$domain.pem" /certs/_default.pem
	fi
	echo "SET certs_$domain " > redis_insert.txt
	cat "/certs/$domain.pem" >> redis_insert.txt
	cat redis_insert.txt | redis-cli -h $REDIS_POST -p $REDIS_PORT -n $REDIS_DATABASE --pipe
	echo "Written to redis";
done

# Reload HAproxy.
if [[ -n "${HAPROXY_IMAGE+1}" ]]; then
	for container in $(docker ps -f ancestor="$HAPROXY_IMAGE" -f status=running -f volume=/etc/letsencrypt -q); do
		echo "Reloading HAproxy container: $container"
		docker exec "$container" /reload.sh
	done
fi
