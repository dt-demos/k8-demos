#!/bin/bash

# load in the shared library and validate argument
. ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

export DT_TENANT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
export DT_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')

DT_LATEST_RELEASE="v0.8.0"

echo "------------------------------------------------------------"
echo "Installing OneAgent Operator version : $DT_LATEST_RELEASE"
echo "------------------------------------------------------------"
echo "Creating namespace dynatrace"
kubectl create namespace dynatrace
echo "Installing Dynatrace Operator"
kubectl apply -f https://github.com/Dynatrace/dynatrace-oneagent-operator/releases/download/$DT_LATEST_RELEASE/kubernetes.yaml
echo ""

echo "------------------------------------------------------------"
echo "Letting Dynatrace OneAgent operator start up [60 seconds]"
sleep 60

echo "------------------------------------------------------------"
echo "Creating dynatrace secret"
kubectl -n dynatrace create secret generic oneagent --from-literal="apiToken=$DT_API_TOKEN" --from-literal="paasToken=$DT_PAAS_TOKEN"

if [ -f ./manifests/gen/cr.yml ]; then
  rm -f ./manifests/gen/cr.yml
fi

echo "Creating dynatrace secret"
mkdir -p ./manifests/gen/dynatrace
$ curl -o cr.yaml https://raw.githubusercontent.com/Dynatrace/dynatrace-oneagent-operator/master/deploy/cr.yaml
curl -o ./manifests/gen/dynatrace/cr.yml https://raw.githubusercontent.com/Dynatrace/dynatrace-oneagent-operator/$DT_LATEST_RELEASE/deploy/cr.yaml
cat ./manifests/gen/dynatrace/cr.yml | sed 's/ENVIRONMENTID.live.dynatrace.com/'"$DT_TENANT_HOSTNAME"'/' >> ./manifests/gen/cr.yml
kubectl create -f ./manifests/gen/cr.yml

echo "------------------------------------------------------------"
echo "OneAgent Operator installation complete"
echo "------------------------------------------------------------"
