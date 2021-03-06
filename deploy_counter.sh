#!/bin/bash
#
# Copyright 2017 IBM Corp. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Load configuration variables
source local.env

function usage() {
  echo -e "Usage: $0 [--install,--uninstall,--env]"
}

function install() {

  # Exit if any command fails
  set -e

  echo -e "Installing OpenWhisk actions, triggers, and rules for openwhisk-serverless-apis..."

  echo -e "Setting credentials and logging in to provision API Gateway"

  # Edit these to match your Bluemix credentials (needed to provision the API Gateway)
  #wsk bluemix login \
  #  --user $BLUEMIX_USERNAME \
  #  --password $BLUEMIX_PASSWORD \
  #  --namespace $BLUEMIX_NAMESPACE

  # bx login -a api.ng.bluemix.net \
  #    -o $BLUEMIX_ORG \
  #    -s $BLUEMIX_NAMESPACE \
  #    --apikey $BLUEMIX_APIKEY

  #wsk property set --apihost openwhisk.ng.bluemix.net
  #wsk property set --auth 2ca7718c-f5f4-41f5-983a-722d63f96298:9HHklUbPfCRlQbwLjEXg2QkEROHkeX9bNOULPr9aD2JDAsIgeO040cpxjXO4GVgS
  #wsk property set --namespace szwwliao_dev -i


  # Edit these to match your Bluemix credentials (needed to provision the API Gateway)
  wsk property set --apihost https://10.63.89.111:30427
  wsk property set --auth 789c46b1-71f6-4ed5-8c54-816aa4f8c502:abczO3xZCLrMN6v2BKK1dXYFpXlPkccOFqm12CdAsMgRU4VrNZ9lyGVCGuMDGIwP
  wsk property set --namespace whisk.system -i

  echo -e "\n"

  echo "Creating a package (here used as a namespace for shared environment variables)"
  wsk package create counter -i \
    --param "MYSQL_HOSTNAME" $MYSQL_HOSTNAME \
    --param "MYSQL_USERNAME" $MYSQL_USERNAME \
    --param "MYSQL_PASSWORD" $MYSQL_PASSWORD \
    --param "MYSQL_DATABASE" $MYSQL_DATABASE

  echo "Installing POST Counter Action"
  cd actions/counter-post-action
#  npm install
  zip -rq action.zip *
  wsk action create counter/counter-post -i \
    --kind nodejs:6 action.zip \
    --web true
  wsk api create -i -n "Counter API" /v1 /counter POST counter/counter-post
  cd ../..

  echo "Installing increase 1 Counter Action"
  cd actions/counter-inc1-action
 # npm install
  zip -rq action.zip *
  wsk action create counter/counter-inc1 -i \
    --kind nodejs:6 action.zip \
    --web true
  wsk api create -i -n "Counter API" /v1 /counter POST counter/counter-inc1
  cd ../..

  echo "Installing PUT Counter Action"
  cd actions/counter-put-action
  #npm install
  zip -rq action.zip *
  wsk action create counter/counter-put -i \
    --kind nodejs:6 action.zip \
    --web true
  wsk api create -i /v1 /counter PUT counter/counter-put
  cd ../..

  echo "Installing GET Counter Action"
  cd actions/counter-get-action
  #npm install
  zip -rq action.zip *
  wsk action create counter/counter-get -i \
    --kind nodejs:6 action.zip \
    --web true
  wsk api create -i /v1 /counter GET counter/counter-get
  cd ../..

  echo "Installing DELETE Counter Action"
  cd actions/counter-delete-action
 # npm install
  zip -rq action.zip *
  wsk action create counter/counter-delete -i \
    --kind nodejs:6 action.zip \
    --web true
  wsk api create -i /v1 /counter DELETE counter/counter-delete
  cd ../..

  echo -e "Install Complete"
}

function uninstall() {
  echo -e "Uninstalling..."

  echo "Removing API actions..."
  wsk api delete -i /v1

  echo "Removing actions..."
  wsk action delete -i counter/counter-post
  wsk action delete -i counter/counter-inc1
  wsk action delete -i counter/counter-put
  wsk action delete -i counter/counter-get
  wsk action delete -i counter/counter-delete

  echo "Removing package..."
  wsk package delete -i counter

  echo -e "Uninstall Complete"
}

function showenv() {
  echo -e MYSQL_HOSTNAME="$MYSQL_HOSTNAME"
  echo -e MYSQL_USERNAME="$MYSQL_USERNAME"
  echo -e MYSQL_PASSWORD="$MYSQL_PASSWORD"
  echo -e MYSQL_DATABASE="$MYSQL_DATABASE"
  echo -e BLUEMIX_USERNAME="$BLUEMIX_USERNAME"
  echo -e BLUEMIX_PASSWORD="$BLUEMIX_PASSWORD"
}

case "$1" in
"--install" )
install
;;
"--uninstall" )
uninstall
;;
"--env" )
showenv
;;
* )
usage
;;
esac
