#!/bin/sh

echo "Running setup"

TOKEN=${K8S_TOKEN:-<SET-A-TOKEN>} 

kubectl config set-credentials myself --token=${TOKEN}
kubectl config set-cluster lab --server=<SET-A-SERVER>
kubectl config set-context default-context --cluster=<SET-A-CLUSTER> --user=<SET-A-USER>
kubectl config use-context default-context

kubectl config set contexts.default-context.namespace <SET-A-NAMESPACE>
