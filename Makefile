all: tmp srv build run watch serve

tmp:
	@mkdir tmp
	@chmod 777 tmp

srv:
	@mkdir -p srv/images

build: buildphp

buildjs:
	docker build -t joshuacox/image_receiver .

buildphp:
	docker build -t joshuacox/image_receiver:phplistenerfff -f ./Dockerfile.php .

run: clean .cid

.cid: .port
	$(eval ID_U := $(shell id -u))
	$(eval ID_G := $(shell id -g))
	docker run \
		-it \
		--cidfile=.cid \
		-d \
		-p `cat .port`:80 \
		-v `pwd`/tmp:/var/www/html/tmp \
		joshuacox/image_receiver:phplistenerfff

		#-u ${ID_U}:${ID_G} \

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

.cid.nginx: .port.srv .user .pass .host
	docker run \
		-d \
		-it \
		-e 'NGINX_TEMPLATE=default' \
		-e "NGINX_AUTH=true" \
		-e "NGINX_USER=`cat .user`" \
		-e "NGINX_PASS=`cat .pass`" \
		-p `cat .port.srv`:80 \
		-v `pwd`/srv:/usr/share/nginx/html:ro \
		--cidfile=.cid.nginx \
		webhostingcoopteam/nginx-tiny-proxy


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
		-e 'WATCHER_DEBUG=true' \
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

.user:
	@while [ -z "$$NGINX_USER" ]; do \
		read -r -p "Enter the user you wish to associate with this server container [NGINX_USER]: " NGINX_USER; echo "$$NGINX_USER">>.user; cat .user; \
	done ;

.host:
	@while [ -z "$$HOST" ]; do \
		read -r -p "Enter the host you wish to associate with this server container [HOST]: " HOST; echo "$$HOST">>.host; cat .host; \
	done ;

.pass:
	@while [ -z "$$NGINX_PASS" ]; do \
		read -r -p "Enter the pass you wish to associate with this server container [NGINX_PASS]: " NGINX_PASS; echo "$$NGINX_PASS">>.pass; cat .pass; \
	done ;
