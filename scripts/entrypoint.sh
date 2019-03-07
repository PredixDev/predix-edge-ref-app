#!/bin/sh

cp /config/settings.js /data
cp /config/flows.json /data
cp /data/compressor-specs.json /data
source /config/env
ln -s /config testdir
npm start
