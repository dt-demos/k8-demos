#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

CREDS=./creds.json

if [ -f "$CREDS" ]
then
    DT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')
    DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
    DT_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')
    RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
    CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')
fi

clear
echo "==================================================================="
echo "Please enter the values for provider: $DEPLOYMENT_NAME"
echo "Press <enter> to keep the current value"
echo "==================================================================="
echo "Dynatrace Host Name"
read -p "  (e.g. abc12345.live.dynatrace.com)   (current: $DT_HOSTNAME) : " DT_HOSTNAME_NEW
read -p "Dynatrace API Token                    (current: $DT_API_TOKEN) : " DT_API_TOKEN_NEW
read -p "Dynatrace PaaS Token                   (current: $DT_PAAS_TOKEN) : " DT_PAAS_TOKEN_NEW
read -p "Resource Prefix (e.g. lastname)        (current: $RESOURCE_PREFIX) : " RESOURCE_PREFIX_NEW

case $DEPLOYMENT in
  eks)
    read -p "Cluster Region (e.g. us-east-1)        (current: $CLUSTER_REGION) : " CLUSTER_REGION_NEW
    ;;
esac
echo "==================================================================="
echo ""
# set value to new input or default to current value
DT_HOSTNAME=${DT_HOSTNAME_NEW:-$DT_HOSTNAME}
DT_API_TOKEN=${DT_API_TOKEN_NEW:-$DT_API_TOKEN}
DT_PAAS_TOKEN=${DT_PAAS_TOKEN_NEW:-$DT_PAAS_TOKEN}
CLUSTER_REGION=${CLUSTER_REGION_NEW:-$CLUSTER_REGION}
RESOURCE_PREFIX=${RESOURCE_PREFIX_NEW:-$RESOURCE_PREFIX}

echo -e "Please confirm all are correct:"
echo ""
echo "Dynatrace Host Name          : $DT_HOSTNAME"
echo "Dynatrace API Token          : $DT_API_TOKEN"
echo "Dynatrace PaaS Token         : $DT_PAAS_TOKEN"
echo "Resource Prefix              : $RESOURCE_PREFIX"

case $DEPLOYMENT in
  eks)
    echo "Cluster Region               : $CLUSTER_REGION"
    ;;
esac
echo "==================================================================="
read -p "Is this all correct? (y/n) : " -n 1 -r
echo ""
echo "==================================================================="

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Making a backup file: $CREDS.bak"
    cp $CREDS $CREDS.bak 2> /dev/null
    rm $CREDS 2> /dev/null

    cat ./creds.sav | \
      sed 's~DEPLOYMENT_PLACEHOLDER~'"$DEPLOYMENT"'~' | \
      sed 's~DYNATRACE_HOSTNAME_PLACEHOLDER~'"$DT_HOSTNAME"'~' | \
      sed 's~DYNATRACE_API_TOKEN_PLACEHOLDER~'"$DT_API_TOKEN"'~' | \
      sed 's~DYNATRACE_PAAS_TOKEN_PLACEHOLDER~'"$DT_PAAS_TOKEN"'~' | \
      sed 's~RESOURCE_PREFIX_PLACEHOLDER~'"$RESOURCE_PREFIX"'~' > $CREDS

    case $DEPLOYMENT in
      eks)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~CLUSTER_REGION_PLACEHOLDER~'"$CLUSTER_REGION"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
    esac
    echo ""
    echo "Making credentials file: $CREDS"
    echo ""
fi