all: gatherinfo opencvUploads tmp srv build run watch serve opencv

gatherinfo: .host .port .port.opencv .port.srv .user .pass

tmp:
	@mkdir tmp
	@chmod 777 tmp

srv:
	@mkdir -p srv/images

opencvUploads:
	@mkdir -p opencvUploads

CURRENT_LANG=python

build: build${CURRENT_LANG}
exec: ${CURRENT_LANG}exec
logs: ${CURRENT_LANG}logs
kill: ${CURRENT_LANG}kill
rm: ${CURRENT_LANG}rm

buildjs:
	docker build -t joshuacox/image_receiver:jslistener -f Dockerfile.js .

buildphp:
	docker build -t joshuacox/image_receiver:phplistener -f ./Dockerfile.php .

buildpython:
	docker build -t joshuacox/image_receiver:pythonlistener -f ./Dockerfile.python .

run: clean .cid.${CURRENT_LANG}

php: .cid.php

.cid.php: .port
	$(eval ID_U := $(shell id -u))
	$(eval ID_G := $(shell id -g))
	docker run \
		-it \
		--cidfile=.cid.php \
		-d \
		-p `cat .port`:80 \
		-v `pwd`/tmp:/var/www/html/tmp \
		joshuacox/image_receiver:phplistener

		#-u ${ID_U}:${ID_G} \

.cid.js: .port
	$(eval ID_U := $(shell id -u))
	$(eval ID_G := $(shell id -g))
	docker run \
		-it \
		--cidfile=.cid.js \
		-d \
		-u ${ID_U}:${ID_G} \
		-p `cat .port`:8080 \
		-v `pwd`/tmp:/tmp \
		joshuacox/image_receiver:jslistener

.cid.python: .port
	$(eval ID_U := $(shell id -u))
	$(eval ID_G := $(shell id -g))
	docker run \
		-it \
		--cidfile=.cid.python \
		-d \
		-u ${ID_U}:${ID_G} \
		-p `cat .port`:8888 \
		-v `pwd`/tmp:/tmp \
		joshuacox/image_receiver:pythonlistener


${CURRENT_LANG}exec:
	-@docker exec -it `cat .cid.${CURRENT_LANG}` /bin/sh

${CURRENT_LANG}logs:
	-@docker logs `cat .cid.${CURRENT_LANG}`

${CURRENT_LANG}kill:
	-@docker kill `cat .cid.${CURRENT_LANG}`

${CURRENT_LANG}rm:
	-@docker rm `cat .cid.${CURRENT_LANG}`
	-@rm .cid.${CURRENT_LANG}

pyexec:
	-@docker exec -it `cat .cid.python` /bin/sh

pylogs:
	-@docker logs `cat .cid.python`

pykill:
	-@docker kill `cat .cid.python`

pyrm:
	-@docker rm `cat .cid.python`
	-@rm .cid.python

jsexec:
	-@docker exec -it `cat .cid.js` /bin/sh

jslogs:
	-@docker logs `cat .cid.js`

jskill:
	-@docker kill `cat .cid.js`

jsrm:
	-@docker rm `cat .cid.js`
	-@rm .cid.js

clean: kill rm watch_clean serve_clean opencv_clean

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

.cid.watch: .port.opencv
	$(eval ID_U := $(shell id -u)) 
	$(eval ID_G := $(shell id -g))
	docker run \
		-d \
		-it \
		-u ${ID_U}:${ID_G} \
		-v `pwd`/opencvUploads:/opencvUploads \
		-v `pwd`/tmp:/tmp \
		-v `pwd`/srv:/srv \
		-p `cat .port.opencv`:8080 \
		-e 'WATCHER_DEBUG=true' \
		--cidfile=.cid.watch \
		joshuacox/watcher

opencv: .cid.opencv

opencv_build:
	@cd opencv; docker build -t joshuacox/image_receiver:opencvwatcher .

opencv_clean:
	-@docker kill `cat .cid.opencv`
	-@docker rm `cat .cid.opencv`
	-@rm .cid.opencv

opencv_logs:
	-@docker logs `cat .cid.opencv`

opencv_exec:
	-@docker exec -it `cat .cid.opencv` /bin/bash

.cid.opencv: opencv_clean opencv_build
	$(eval ID_U := $(shell id -u))
	$(eval ID_G := $(shell id -g))
	docker run \
		-d \
		-it \
		-u ${ID_U}:${ID_G} \
		-v `pwd`/opencvUploads:/opencvUploads \
		-v `pwd`/srv:/srv \
		--cidfile=.cid.opencv \
		joshuacox/image_receiver:opencvwatcher

.port.opencv:
	@while [ -z "$$PORTOPENCV" ]; do \
		read -r -p "Enter the port you wish to associate with this server container [PORTOPENCV]: " PORTOPENCV; echo "$$PORTOPENCV">>.port.opencv; cat .port.opencv; \
	done ;

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
