#!/bin/sh
set -e
rootDir=$quickstartRootDir
logDir="$rootDir/log"

# Predix Dev Bootstrap Script
# Authors: GE SDLP 2015
#
# Welcome new Predix Developers! Run this script to instal application specific repos,
# edit the manifest.yml file, build the application, and push the application to cloud foundry
#

# Be sure to set all your variables in the variables.sh file before you run quick start!
# source "$rootDir/bash/scripts/variables.sh"
# source "$rootDir/bash/scripts/error_handling_funcs.sh"
# source "$rootDir/bash/scripts/files_helper_funcs.sh"
# source "$rootDir/bash/scripts/curl_helper_funcs.sh"

trap "trap_ctrlc" 2
logDir="/data"
if ! [ -d "$logDir" ]; then
  logDir="data"
  chmod 744 "$logDir"
fi
touch "$logDir/quickstart.log"

echo "$*"
APP_NAME=$1

# ********************************** MAIN **********************************

#	----------------------------------------------------------------
#	Function called by quickstart.sh, must be spelled main()
#		Accepts 1 arguments:
#			string of app name used to bind to services so we can get VCAP info
#	----------------------------------------------------------------
function main() {
  if [[ $RUN_CREATE_PACKAGES == 1 ]]; then
    echo "Creating Packages"
    createPackages $APP_NAME
  fi
}

function createPackages {
  APP_NAME_CONFIG="$APP_NAME-config.zip"
  echo "APP_NAME=$APP_NAME"
  CURDIR=`pwd`
  if [[ -e /data/$APP_NAME ]]; then
    rm -rf /data/$APP_NAME
  elif [[ -e data/$APP_NAME ]]; then
    rm -rf data/$APP_NAME
  fi

  if [[ -e /data ]]; then
    mkdir -p /data/$APP_NAME
  elif [[ -e data ]]; then
    mkdir -p data/$APP_NAME
  fi

  if [[ -e /config ]]; then
      cd /config
  elif [[ -e config ]]; then
      cd config
  fi

  #no extensions
  for file in `find . -type f -maxdepth 1 ! -name '*.*' | grep -v '\./\.' | sed 's|\./||' | sort -u`;  do
    echo "file=$file"
    extensions="$extensions $file"
  done
  #files with extensions
  for extension in `find . -type f -maxdepth 1 -name '*.*' | grep -v '\./\.' | sed 's|.*\.||' | sort -u`;  do
    echo "extension=$extension"
    extensions="$extensions *.$extension"
  done
  echo $extensions
  if [[ -d /data ]]; then
    for file in $extensions; do
      cp $file /data/$APP_NAME
    done
    cp /data/flows.json /data/$APP_NAME
    cd /data/$APP_NAME
  elif [[ -d data ]]; then
    for file in $extensions; do
      cp $file $CURDIR/data/$APP_NAME
    done
    cp data/flows.json $CURDIR/data/$APP_NAME
    cd $CURDIR/data/$APP_NAME
  fi

  echo "Compressing the configurations."
  if [[ -e /data/$APP_NAME ]]; then
    zip -X -r /data/$APP_NAME/$APP_NAME_CONFIG $extensions
  elif [[ -e $CURDIR/data/$APP_NAME ]]; then
    zip -X -r $CURDIR/data/$APP_NAME/$APP_NAME_CONFIG $extensions
  else
    echo "unable to zip, dir /data/$APP_NAME or data/$APP_NAME does not exist"
  fi

  echo "Packaged $APP_NAME_CONFIG"

  echo "Creating Packages for $APP_NAME complete"
}

RUN_CREATE_PACKAGES=1
main
