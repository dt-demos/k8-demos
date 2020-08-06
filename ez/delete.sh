#!/bin/sh

echo "Deleting easyTravel"
kubectl delete -f config.yaml

echo "Deleting loadgen"
kubectl delete -f loadgen.yaml

echo "Deleting namespace"
kubectl delete ns easytravel
