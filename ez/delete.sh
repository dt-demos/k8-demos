#!/bin/sh

echo "Deleting easyTravel"
kubectl delete -f config.yaml

echo "Deleting loadgen"
kubectl delete -f loadgen.yaml
