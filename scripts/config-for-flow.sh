#!/bin/bash
dir=$1

if [[ $# -eq 0 ]]; then
  echo "1 argument expected.  Pass the name of the dir containing the flow relative to the config dir. e.g. ./scripts/config-for-flow.sh app-deadband"
  exit 1
fi

cd config/$1
pwd
if [ ! -e settings.js ]; then
  cp ../settings.js .
fi
cp ../config-cloud-gateway.json .
cp ../config-opcua.json .
cp ../config-simulator.json .
cp flows-$1.json flows.json
rm -f predix-edge-ref-app-$1-config.zip
zip -X -r predix-edge-ref-app-$1-config.zip * -x ..
