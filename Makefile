all: prepare build push

prepare:
	docker pull alpine:3.6

build:
	docker build -t gone/docker-haproxy-letsencrypt --no-cache .

push:
	docker push gone/docker-haproxy-letsencrypt