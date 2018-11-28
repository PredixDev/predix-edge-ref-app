#!/bin/bash
HOME_DIR=$(pwd)

set -e

RUN_QUICKSTART=1
SKIP_PREDIX_SERVICES=false
BUILD_APP=false
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
    --skip-predix-services)
      SKIP_PREDIX_SERVICES=true
    ;;
    --build-app)
      BUILD_APP=true
    ;;
    -o|--override)
      QUICKSTART_ARGS=" $SCRIPT"
    ;;
    --skip-setup)
      SKIP_SETUP=true
    ;;
    --no-cloud)
      NO_CLOUD=true
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

IZON_SH="https://raw.githubusercontent.com/PredixDev/izon/1.2.0/izon2.sh"
#ASSET_MODEL="-amrmd predix-ui-seed/server/sample-data/predix-asset/asset-model-metadata.json predix-ui-seed/server/sample-data/predix-asset/asset-model.json"
#SCRIPT="-script build-basic-app.sh -script-readargs build-basic-app-readargs.sh"
SCRIPT="-script edge-starter-deploy.sh -script-readargs edge-starter-deploy-readargs.sh"
VERSION_JSON="version.json"
PREDIX_SCRIPTS="predix-scripts"
REPO_NAME="predix-edge-ref-app"
SCRIPT_NAME="quickstart-edge-ref-app-local.sh"
GITHUB_RAW="https://raw.githubusercontent.com/PredixDev"
APP_DIR="edge-ref-app-local"
APP_NAME="Predix Edge Reference App - local"

TOOLS="Cloud Foundry CLI, Docker, Git, jq, yq, Node.js, Predix CLI"
TOOLS_SWITCHES="--cf --docker --git --jq --yq --nodejs --predixcli"

TIMESERIES_CHART_ONLY="true"

# Process switches
local_read_args $@

#variables after processing switches
SCRIPT_LOC="$GITHUB_RAW/$REPO_NAME/$BRANCH/scripts/$SCRIPT_NAME"
VERSION_JSON_URL="$GITHUB_RAW/$REPO_NAME/$BRANCH/version.json"

if [[ "$SKIP_PREDIX_SERVICES" == "false" ]]; then
  QUICKSTART_ARGS="$QUICKSTART_ARGS -uaa -ts -psts -app-name $REPO_NAME --run-edge-app -p $SCRIPT"
else
  QUICKSTART_ARGS="$QUICKSTART_ARGS -app-name $REPO_NAME --run-edge-app -p $SCRIPT"
fi

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

  check_internet

  #get the script that reads version.json
  eval "$(curl -s -L $IZON_SH)"

  #download script and cd
  getUsingCurl $SCRIPT_LOC
  chmod 755 $SCRIPT_NAME;
  if [[ ! $currentDir == *"$REPO_NAME" ]]; then
    mkdir -p $APP_DIR
    cd $APP_DIR
  fi

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
rm -rf predix-scripts/$REPO_NAME
getCurrentRepo

echo "docker images"
docker images

if [[ "$BUILD_APP" == "true" ]]; then
  cd $PREDIX_SCRIPTS/$REPO_NAME
  echo "docker build --build-arg HTTP_PROXY --build-arg HTTPS_PROXY --build-arg http_proxy --build-arg https_proxy -t predixadoption/predix-edge-ref-app:latest ."
  docker build --build-arg HTTP_PROXY --build-arg HTTPS_PROXY --build-arg http_proxy --build-arg https_proxy -t predixadoption/predix-edge-ref-app:latest .
  cd ../..
fi
echo "quickstart_args=$QUICKSTART_ARGS"
source $PREDIX_SCRIPTS/bash/quickstart.sh $QUICKSTART_ARGS

echo "docker stack ls"
docker stack ls
echo "docker stack services $REPO_NAME"
docker stack services $REPO_NAME
echo "docker ps"
docker ps

# Automagically open the application in browser, based on OS
echo "SKIP_BROWSER : $SKIP_BROWSER"
if [[ $SKIP_BROWSER == 0 ]]; then
  app_url="http://127.0.0.1:5000"

  case "$(uname -s)" in
     Darwin)
       # OSX
       open $app_url
       ;;
     Linux)
       # Linux
       if [[ $( which xdg-open | wc -l ) == 1 ]]; then
         xdg-open $app_url
       fi
       ;;
     CYGWIN*|MINGW32*|MINGW64*|MSYS*)
       # Windows
       start "" $app_url
       ;;
  esac
fi
cat $SUMMARY_TEXTFILE
if [[ $SKIP_PREDIX_SERVICES == false ]]; then
  __append_new_line_log "To see the data in the cloud, using a browser, open the Front-end App URL shown above.  With login=app_user_1, password=App_User_111" "$quickstartLogDir"
fi
__append_new_line_log "" "$logDir"
__append_new_line_log "Successfully completed Edge Ref App installation!" "$quickstartLogDir"
__append_new_line_log "" "$logDir"
