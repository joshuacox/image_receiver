FROM alpine:3.10
RUN apk add --no-cache bash gettext inotify-tools file curl
COPY ./watcher /watcher/watcher
COPY ./index.tpl watcher/index.tpl
WORKDIR /watcher
ENTRYPOINT ["./watcher", "/tmp"]
