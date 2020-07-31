#!/bin/sh

echo "Creating easyTravel"
kubectl create -f config.yaml

echo "Waiting for 150 seconds before starting loadgen"
sleep 150
kubectl create -f loadgen.yaml
