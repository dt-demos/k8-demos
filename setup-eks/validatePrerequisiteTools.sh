#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
export DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

echo "=============================================================================="
echo "Validating Common pre-requisites"
echo "=============================================================================="

echo -n "jq utility        "
command -v jq &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'jq' json query utility"
    echo ""
    exit 1
fi
echo "ok	$(command -v jq)"

echo -n "yq utility        "
command -v yq &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'yq' json query utility"
    echo ""
    exit 1
fi
echo "ok	$(command -v yq)"

echo -n "kubectl           "
command -v kubectl &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'kubectl'"
    echo ""
    exit 1
fi
echo "ok	$(command -v kubectl)"

case $DEPLOYMENT in
  eks)
    echo "=============================================================================="
    echo "Validating EKS pre-requisites"
    echo "=============================================================================="
    echo -n "AWS cli           "
    command -v aws &> /dev/null
    if [ $? -ne 0 ]; then
      echo "Error"
      echo ">>> Missing 'aws CLI'"
      echo ""
      exit 1
    fi
    echo "ok	$(command -v aws)"

    echo -n "eksctl            "
    command -v eksctl &> /dev/null
    if [ $? -ne 0 ]; then
      echo "Error"
      echo ">>> Missing 'eksctl'"
      echo ""
      exit 1
    fi
    echo "ok	$(command -v eksctl)"

    echo -n "aws-iam-auth      "
    command -v aws-iam-authenticator &> /dev/null
    if [ $? -ne 0 ]; then
      echo "Error"
      echo ">>> Missing 'aws-iam-authenticator'"
      echo ""
      exit 1
    fi
    echo "ok	$(command -v aws-iam-authenticator)"

    echo -n "AWS cli           "
    export AWS_STS_USER=$(aws sts get-caller-identity | jq -r '.UserId')
    if [ -z $AWS_STS_USER ]; then
      echo ">>> aws cli not configured.  Configure by running \"aws configure\""
      echo ""
      exit 1
    fi
    echo "ok    configured with UserId: $AWS_STS_USER"
    ;;
  esac

echo "=============================================================================="
echo "Validation of pre-requisites complete"
echo "=============================================================================="
