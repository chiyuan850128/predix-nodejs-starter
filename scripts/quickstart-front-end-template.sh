#!/bin/bash
set -e

function local_read_args() {
  while (( "$#" )); do
  opt="$1"
  case $opt in
    -h|-\?|--\?--help)
      PRINT_USAGE=1
      QUICKSTART_ARGS=" $1"
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

IZON_SH="https://raw.githubusercontent.com/PredixDev/izon/1.2.0/izon2.sh"
BRANCH="master"
PRINT_USAGE=0
SKIP_SETUP=false
#ASSET_MODEL="-amrmd predix-ui-seed/server/sample-data/predix-asset/asset-model-metadata.json predix-ui-seed/server/sample-data/predix-asset/asset-model.json"
SCRIPT="-script build-basic-app.sh -script-readargs build-basic-app-readargs.sh"
QUICKSTART_ARGS="-ns $SCRIPT"
VERSION_JSON="version.json"
PREDIX_SCRIPTS=predix-scripts
REPO_NAME=predix-nodejs-starter
SCRIPT_NAME="quickstart-front-end-template.sh"
APP_DIR="frontend-microservice-template"
APP_NAME="Predix Front End WebApp Microservice Template"
GITHUB_RAW="https://raw.githubusercontent.com/PredixDev"
TOOLS="Cloud Foundry CLI, Git, Node.js, Predix CLI"
TOOLS_SWITCHES="--cf --git --nodejs --predixcli"

# Process switches
local_read_args $@

#variables after processing switches
echo "branch=$BRANCH"
SCRIPT_LOC="$GITHUB_RAW/$REPO_NAME/$BRANCH/scripts/$SCRIPT_NAME"
VERSION_JSON_URL="$GITHUB_RAW/$REPO_NAME/$BRANCH/version.json"
echo "VERSION_JSON_URL=$VERSION_JSON_URL"

function check_internet() {
  set +e
  echo ""
  echo "Checking internet connection..."
  curl "http://github.com" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Unable to connect to internet, make sure you are connected to a network and check your proxy settings if behind a corporate proxy"
    echo "If you are behind a corporate proxy, set the 'http_proxy' and 'https_proxy' environment variables."
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
  
  #download the script and cd
  getUsingCurl $SCRIPT_LOC
  chmod 755 $SCRIPT_NAME
  if [[ ! $currentDir == *"$REPO_NAME" ]]; then
    mkdir -p $APP_DIR
    cd $APP_DIR
  fi

  
  getVersionFile
  getLocalSetupFuncs $GITHUB_RAW
}

if [[ $PRINT_USAGE == 1 ]]; then
  __print_out_usage
  init
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

echo "quickstart_args=$QUICKSTART_ARGS"
source $PREDIX_SCRIPTS/bash/quickstart.sh $QUICKSTART_ARGS

__append_new_line_log "Successfully completed $APP_NAME installation!" "$quickstartLogDir"
__append_new_line_log "" "$quickstartLogDir"

