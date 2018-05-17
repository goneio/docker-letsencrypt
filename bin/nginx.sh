#!/bin/bash

set -e

mkdir -p /run/nginx

dockerize -template /opt/letsencrypt/etc/nginx.tmpl.conf:/opt/letsencrypt/etc/nginx.conf

mkdir /opt/www
chmod 777 /opt/www

exec nginx -c /opt/letsencrypt/etc/nginx.conf "$@"
