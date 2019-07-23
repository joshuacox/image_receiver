all: build run

build:
	docker build -t monitaur/image_receiver .

run: clean .cid

.cid:
	docker run \
		-it \
		--cidfile=.cid \
		-d \
		-p 3000:3000 \
		monitaur/image_receiver

kill:
	-docker kill `cat .cid`

rm:
	-docker rm `cat .cid`
	-rm .cid

clean: kill rm
