FROM alpine:3.10
RUN apk add --no-cache bash gettext inotify-tools
COPY ./watcher /watcher/watcher
WORKDIR /watcher
ENTRYPOINT ["./watcher", "/tmp"]
