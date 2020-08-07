#!/bin/bash

export DT_TENANT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')

echo ""
echo "-------------------------------------------------------------------------------"
echo "kubectl -n dynatrace get pods"
echo "-------------------------------------------------------------------------------"
kubectl -n dynatrace get pods

echo ""
echo "-------------------------------------------------------------------------------"
echo "Dynatrace URL: https://$DT_TENANT_HOSTNAME"

