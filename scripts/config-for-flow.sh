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

extensions=''
#no extensions
for file in `find . -type f -depth 1 ! -name '*.*' | grep -v '\./\.' | sed 's|\./||' | sort -u`;  do
  echo "file=$file"
  extensions="$extensions $file"
done
#files with extensions
for extension in `find . -type f -depth 1 -name '*.*' | grep -v '\./\.' | sed 's|.*\.||' | sort -u`;  do
  echo "extension=$extension"
  extensions="$extensions *.$extension"
done
echo $extensions
zip -X -r ../$APP_NAME_CONFIG $extensions
zip -X -r predix-edge-ref-app-$1-config.zip $extensions
