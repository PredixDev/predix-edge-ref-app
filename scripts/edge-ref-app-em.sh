#!/bin/bash
HOME_DIR=$(pwd)
set -e

RUN_QUICKSTART=1
SKIP_PREDIX_SERVICES="false"
function local_read_args() {
  while (( "$#" )); do
  opt="$1"
  case $opt in
    -h|-\?|--\?--help)
      PRINT_USAGE=1
      QUICKSTART_ARGS="$SCRIPT $1"
      break
    ;;
    -b|--branch)
      BRANCH="$2"
      QUICKSTART_ARGS+=" $1 $2"
      shift
    ;;
    -o|--override)
      QUICKSTART_ARGS=" $SCRIPT"
    ;;
    --skip-setup)
      SKIP_SETUP=true
    ;;
    *)
      QUICKSTART_ARGS+=" $1"
      #echo $1
    ;;
  esac
  shift
  done

  if [[ -z $BRANCH ]]; then
    echo "Usage: $0 -b/--branch <branch> [--skip-setup]"
    exit 1
  fi
}



# default settings
BRANCH="master"
PRINT_USAGE=0
SKIP_SETUP=false

IZON_SH="https://raw.githubusercontent.com/PredixDev/izon/1.1.0/izon2.sh"
SCRIPT="-script edge-manager.sh  -script-readargs edge-manager-readargs.sh"
QUICKSTART_ARGS="$QUICKSTART_ARGS -p -cp -cd -ca -cc -ed -edge-app-name edge-ref-app $SCRIPT"
VERSION_JSON="version.json"
PREDIX_SCRIPTS=predix-scripts
REPO_NAME=edge-ref-app
SCRIPT_NAME="edge-ref-app-em.sh"
GITHUB_RAW="https://raw.githubusercontent.com/PredixDev"
APP_DIR="edge-ref-app-em"
APP_NAME="Predix Front End Basic App - Node.js Express with UAA, Asset, Time Series"
TOOLS="Cloud Foundry CLI, Git, Node.js, Predix CLI"
TOOLS_SWITCHES="--cf --git --nodejs --predixcli"
TIMESERIES_CHART_ONLY="true"

# Process switches
local_read_args $@

#variables after processing switches
SCRIPT_LOC="$GITHUB_RAW/$REPO_NAME/$BRANCH/scripts/$SCRIPT_NAME"
VERSION_JSON_URL=https://raw.githubusercontent.com/PredixDev/$REPO_NAME/$BRANCH/version.json

#if [[ "$SKIP_PREDIX_SERVICES" == "false" ]]; then
#  QUICKSTART_ARGS="$QUICKSTART_ARGS --run-edge-app -p $SCRIPT"
#else
#  QUICKSTART_ARGS="$QUICKSTART_ARGS -uaa -ts -psts --run-edge-app -p $SCRIPT"
#fi

function check_internet() {
  set +e
  echo ""
  echo "Checking internet connection..."
  curl "http://google.com" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Unable to connect to internet, make sure you are connected to a network and check your proxy settings if behind a corporate proxy"
    echo "If you are behind a corporate proxy, set the 'http_proxy' and 'https_proxy' environment variables.   Please read this tutorial for detailed info about setting your proxy https://www.predix.io/resources/tutorials/tutorial-details.html?tutorial_id=1565"
    exit 1
  fi
  echo "OK"
  echo ""
  set -e
}

function init() {
  currentDir=$(pwd)
  if [[ $currentDir == *"scripts" ]]; then
    echo 'Please launch the script from the root dir of the project'
    exit 1
  fi
  if [[ ! $currentDir == *"$REPO_NAME" ]]; then
    mkdir -p $APP_DIR
    cd $APP_DIR
  fi

  check_internet

  #get the script that reads version.json
  eval "$(curl -s -L $IZON_SH)"
  curl -O $SCRIPT_LOC; chmod 755 $SCRIPT_NAME;
  getVersionFile
  getLocalSetupFuncs $GITHUB_RAW
}

if [[ $PRINT_USAGE == 1 ]]; then
  init
  __print_out_standard_usage
else
  if $SKIP_SETUP; then
    init
  else
    init
    __standard_mac_initialization
  fi
fi

getPredixScripts
#clone the repo itself if running from oneclick script
getCurrentRepo

docker images

#count=$(docker images "nodered/node-red-docker" -q | wc -l | tr -d " ")
#if [[ $count == 0 ]]; then
#  if [[ ! -d "edge-node-red" ]]; then
    #git clone https://github.com/PredixDev/edge-node-red.git
#  fi
  #cd edge-node-red
  #docker build --build-arg HTTP_PROXY=$HTTP_PROXY --build-arg HTTPS_PROXY=$HTTPS_PROXY -t edge-node-red:latest .
  #docker images
  #cd ..
#else
#  echo "nodered image already present"
#fi
#echo "Edge Node Red image built"

#Build the application
#cd $PREDIX_SCRIPTS/$REPO_NAME
#npm install
#bower install
#./node_modules/gulp/bin/gulp.js dist
#cd ../..
#Build Application end

echo "quickstart_args=$QUICKSTART_ARGS"
source $PREDIX_SCRIPTS/bash/quickstart.sh $QUICKSTART_ARGS

echo "33"
docker images

docker stack ls
docker stack services edge-ref-app
docker ps
# Automagically open the application in browser, based on OS
echo "SKIP_BROWSER : $SKIP_BROWSER"
if [[ $SKIP_BROWSER == 0 ]]; then
  app_url="http://localhost:5000"

  case "$(uname -s)" in
     Darwin)
       # OSX
       open $app_url
       ;;
     Linux)
       # OSX
       xdg-open $app_url
       ;;
     CYGWIN*|MINGW32*|MINGW64*|MSYS*)
       # Windows
       start "" $app_url
       ;;
  esac
fi
cat $SUMMARY_TEXTFILE
__append_new_line_log "" "$logDir"
__append_new_line_log "Successfully completed Edge Ref App installation!" "$quickstartLogDir"
__append_new_line_log "" "$logDir"
