FROM alpine:3.10
RUN apk add --no-cache bash gettext inotify-tools file netcat-openbsd
ENTRYPOINT ["nc", "-lp", "80"]
