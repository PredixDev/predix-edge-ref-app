#!/bin/bash
HOME_DIR=$(pwd)
set -e
LOGIN=1
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
    --skip-predix-services)
      SKIP_PREDIX_SERVICES="true"
      LOGIN=0
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

REPO_NAME=predix-edge-ref-app
IZON_SH="https://raw.githubusercontent.com/PredixDev/izon/1.2.0/izon2.sh"
SCRIPT="-script edge-manager.sh  -script-readargs edge-manager-readargs.sh"
QUICKSTART_ARGS="$QUICKSTART_ARGS --create-packages --upload-application --upload-configuration --create-device -edge-app-name $REPO_NAME -asset-name Compressor-CMMS-Compressor-2018 $SCRIPT"
VERSION_JSON="version.json"
PREDIX_SCRIPTS=predix-scripts

SCRIPT_NAME="quickstart-edge-ref-app-em.sh"
GITHUB_RAW="https://raw.githubusercontent.com/PredixDev"
APP_DIR="edge-ref-app-local"
APP_NAME="Predix Edge Reference App - edge manager"
TOOLS="Cloud Foundry CLI, Docker, Git, JQ, Node.js, Predix CLI, YQ"
TOOLS_SWITCHES="--cf --docker --git --jq --nodejs --predixcli --yq"
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
  #curl -O $SCRIPT_LOC; chmod 755 $SCRIPT_NAME;
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

echo "SKIP_PREDIX_SERVICES : $SKIP_PREDIX_SERVICES"
echo "LOGIN : $LOGIN"

if [[ -e 'predix-scripts' ]]; then
  echo "quickstart_args=$QUICKSTART_ARGS"
  source $PREDIX_SCRIPTS/bash/quickstart.sh $QUICKSTART_ARGS
else
  echo "Please run quickstart-edge-ref-app-local.sh first before running this script."
  exit 1
fi

echo "Created Device $DEVICE_ID in Edge Manager and uploaded the Edge Application and Configuration to repository in Edge Manager."
echo "Your Edge Manager url is https://$EM_TENANT_ID.edgemanager.run.aws-usw02-pr.ice.predix.io"
echo "Next, go to Predix Edge Technician Console and Enroll the Edge OS with Edge Manager. You can access the Predix Edge Technician Console at https://$DEVICE_IP_ADDRESS"
echo "Then deploy the Applcation and Configuration to Edge OS."
echo "Once the deployment of application and configuration is successfull, Open in Browser at https://$DEVICE_IP_ADDRESS:5000"

cat $SUMMARY_TEXTFILE
__append_new_line_log "" "$logDir"
__append_new_line_log "Successfully completed Edge Ref App installation!" "$quickstartLogDir"
__append_new_line_log "" "$logDir"
