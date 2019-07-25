all: tmp srv build run watch serve

tmp:
	@mkdir tmp

srv:
	@mkdir -p srv/images

build:
	docker build -t joshuacox/image_receiver .

run: clean .cid

.cid: .port
	$(eval ID_U := $(shell id -u))
	$(eval ID_G := $(shell id -g))
	docker run \
		-it \
		--cidfile=.cid \
		-d \
		-u ${ID_U}:${ID_G} \
		-p `cat .port`:8080 \
		-v `pwd`/tmp:/tmp \
		joshuacox/image_receiver

exec:
	-@docker exec -it `cat .cid` /bin/sh

logs:
	-@docker logs `cat .cid`

kill:
	-@docker kill `cat .cid`

rm:
	-@docker rm `cat .cid`
	-@rm .cid

clean: kill rm watch_clean serve_clean

tensorflow: .cid.tf

.cid.tf:
	$(eval ID_U := $(shell id -u))
	$(eval ID_G := $(shell id -g))
	docker run \
		-it \
		-p 8888:8888 \
		--cidfile=.cid.tf \
		-v `pwd`/tmp:/tmp \
		-u ${ID_U}:${ID_G} \
		tensorflow/tensorflow:latest-py3-jupyter \
		/bin/bash

serve: serve_clean .cid.nginx

.cid.nginx: .port.srv
	docker run \
		-d \
		-it \
		-p `cat .port.srv`:80 \
		-v `pwd`/srv:/usr/share/nginx/html:ro \
		--cidfile=.cid.nginx \
		nginx:alpine

serve_clean:
	-@docker kill `cat .cid.nginx`
	-@docker rm `cat .cid.nginx`
	-@rm .cid.nginx

watch: watch_build watch_clean .cid.watch

watch_build:
	@cd watcher; docker build -t joshuacox/watcher .

watch_clean:
	-@docker kill `cat .cid.watch`
	-@docker rm `cat .cid.watch`
	-@rm .cid.watch

watch_logs:
	-@docker logs `cat .cid.watch`

watch_exec:
	-@docker exec -it `cat .cid.watch` /bin/bash

.cid.watch:
	$(eval ID_U := $(shell id -u))
	$(eval ID_G := $(shell id -g))
	docker run \
		-d \
		-it \
		-u ${ID_U}:${ID_G} \
		-v `pwd`/tmp:/tmp \
		-v `pwd`/srv:/srv \
		--cidfile=.cid.watch \
		joshuacox/watcher

.port.srv:
	@while [ -z "$$PORTSRV" ]; do \
		read -r -p "Enter the port you wish to associate with this server container [PORTSRV]: " PORTSRV; echo "$$PORTSRV">>.port.srv; cat .port.srv; \
	done ;

.port:
	@while [ -z "$$PORTLISTENER" ]; do \
		read -r -p "Enter the port you wish to associate with this listener container [PORTLISTENER]: " PORTLISTENER; echo "$$PORTLISTENER">>.port; cat .port; \
	done ;
