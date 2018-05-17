FROM alpine:3.6
MAINTAINER Matthew Baggett <matthew@gone.io>

ENV DOCKERIZE_VERSION=0.4.0 \
    PATH="/opt/letsencrypt/bin:$PATH" \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    REDIS_DATABASE=0

RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
        bash \
        coreutils \
        ca-certificates \
        certbot \
        docker \
        nginx \
        tini \
        wget \
        redis \
    && rm -rf /var/cache/apk/* &&\
    update-ca-certificates && \
    wget -nv -O - "https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz" | tar -xz -C /usr/local/bin/ -f - && \
    ln -s /opt/letsencrypt/bin/certbot.sh /etc/periodic/daily/certbot

EXPOSE 80

ENTRYPOINT ["/sbin/tini", "--", "entrypoint.sh"]
CMD ["run.sh"]

COPY . /opt/letsencrypt/
