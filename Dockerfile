FROM node:alpine
#FROM mhart/alpine-node:4

LABEL maintainer="Predix Builder Relations" 
LABEL hub="https://hub.docker.com"
LABEL org="https://hub.docker.com/u/predixadoption"
LABEL version="1.0.4"
LABEL support="https://forum.predix.io"
LABEL license="https://github.com/PredixDev/predix-docker-samples/blob/master/LICENSE.md"

RUN apk add git
RUN npm config set strict-ssl false && \
    npm install -g bower

WORKDIR /usr/src/edge-ref-app

COPY config ./config
COPY data ./data
COPY gulp_tasks ./gulp_tasks
COPY server ./server
COPY src ./src
COPY images ./images
# COPY test ./test
COPY bower.json gulpfile.js package*.json polymer.json ./

RUN npm install
RUN bower install --allow-root
# RUN gulp dist
RUN ./node_modules/gulp/bin/gulp.js dist

RUN rm -rf ./node_modules
RUN npm install --production

RUN npm dedupe

RUN rm -rf ./bower_components
RUN rm -rf ./cache
RUN rm -rf /root/.npm
RUN rm -rf /root/.cache
RUN rm -rf /root/.gnupg
RUN rm -rf ./gulp_tasks
RUN rm -rf ./server
RUN rm -rf ./src
RUN rm -rf ./images

#RUN rm -rf ./node_modules

CMD [ "cp", "./data/flows.json", "/data/" ]
CMD [ "npm", "start"]

EXPOSE 5000
