all: build run

build:
	docker build -t monitaur/image_receiver .

run: clean .cid

.cid:
	docker run \
		-it \
		--cidfile=.cid \
		-d \
		-p 8080:8080 \
		-v `pwd`/tmp:/tmp \
		monitaur/image_receiver

exec:
	-docker exec -it `cat .cid` /bin/sh

logs:
	-docker logs `cat .cid`

kill:
	-docker kill `cat .cid`

rm:
	-docker rm `cat .cid`
	-rm .cid

clean: kill rm

tensorflow: .cid.tf

.cid.tf:
	$(eval ID_U := $(shell id -u))
	$(eval ID_G := $(shell id -g))
	docker run \
		-it \
		--cidfile=.cid.tf \
		-p 8888:8888 \
		-v `pwd`/tmp:/tmp \
		-u ${ID_U}:${ID_G} \
		tensorflow/tensorflow:latest-py3-jupyter \
		/bin/bash

