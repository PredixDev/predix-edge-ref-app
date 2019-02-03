#!/bin/sh

cp /config/settings.js /data
cp /config/flows.json /data
cp /data/compressor-specs.json /data
npm start
