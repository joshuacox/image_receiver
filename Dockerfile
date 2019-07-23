from node:carbon-alpine
COPY app.js /listener/app.js
WORKDIR /listener
ENTRYPOINT ["node", "/listener/app.js"]
