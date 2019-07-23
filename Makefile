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
