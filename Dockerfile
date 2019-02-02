FROM node:10-alpine
#FROM mhart/alpine-node:4

LABEL maintainer="Predix Builder Relations"
LABEL hub="https://hub.docker.com"
LABEL org="https://hub.docker.com/u/predixadoption"
LABEL repo="predix-edge-ref-app"
LABEL dockerImage="predixadoption/predix-edge-ref-app"
LABEL version="1.0.18"
LABEL support="https://forum.predix.io"
LABEL license="https://github.com/PredixDev/predix-docker-samples/blob/master/LICENSE.md"

RUN apk add git
RUN npm config set strict-ssl false && \
    npm install -g bower

WORKDIR /usr/src/edge-ref-app

#COPY config ./config
#COPY data ./data
COPY gulp_tasks ./gulp_tasks
COPY server ./server
COPY src ./src
COPY images ./images
COPY bower.json gulpfile.js package*.json polymer.json ./

RUN node -v

RUN npm cache clean --force
RUN npm install
RUN npm install natives@1.1.6
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

COPY ./scripts/entry_point.sh .

EXPOSE 5000

ENTRYPOINT ["/usr/src/edge-ref-app/entry_point.sh"]
