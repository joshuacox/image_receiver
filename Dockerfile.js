from node:carbon-alpine
COPY app.js /listener/
COPY package.json /listener/
COPY package-lock.json /listener/
WORKDIR /listener
RUN ls -al
RUN npm i
ENTRYPOINT ["node", "/listener/app.js"]
