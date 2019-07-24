# image_receiver

Minimalist image receiver

listener --> watcher --> server

##### Listener has /tmp

nodejs listens for posts, and writes the file to /tmp/

##### Watcher has both /tmp and /srv

then inotify watches that directory and then writes a new /srv/index.html and moves image over to /srv/images

##### Server has /srv read-only

nginx serves the srv directory

### Install

If you have docker installed and make, then use the makefile:

`make`  will both build and run the docker images locally

### Testing

There is an upload script that uses curl:

`./upload my_title ~/Pictures/file-to-upload.jpg`

### History

Receive Images

started from [here](https://itnext.io/how-to-handle-the-post-request-body-in-node-js-without-using-a-framework-cd2038b93190?gi=a9dcabd27fe3)

moved to [formidable](https://github.com/felixge/node-formidable)
