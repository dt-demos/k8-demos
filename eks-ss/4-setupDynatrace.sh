#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

# validate that have valid dynatrace URL and token
./validateDynatrace.sh
if [ $? -ne 0 ]
then
  exit 1
fi

echo " "
echo "===================================================="
echo "About to setup demo app infrastructure"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key

START_TIME=$(date)

# add Dynatrace Operator
./installDynatraceOperator.sh $DEPLOYMENT

# add Dynatrace Tagging rules
#./applyAutoTaggingRules.sh

echo "----------------------------------------------------"
echo "Letting Dynatrace tagging rules be applied [150 seconds] ..."
sleep 150

echo "===================================================="
echo "Finished setting up demo app infrastructure "
echo "===================================================="
echo "Script start time : "$START_TIME
echo "Script end time   : "$(date)

echo ""
echo ""
