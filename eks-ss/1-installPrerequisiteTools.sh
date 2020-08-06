#!/bin/bash

# verify first running on Ubuntu for the installation scripts
# assume that
if [ "$(uname -a | grep Ubuntu)" == "" ]; then
  echo "Must be running on Ubuntu to run this script"
  exit 1
fi

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

clear
echo "======================================================================"
echo "About to install required tools"
echo "Deployment Type: $DEPLOYMENT"
echo ""
echo "NOTE: this will download and copy the executable into /usr/local/bin"
echo "      if the utility finds a value when running 'command -v <utility>'"
echo "      that utility will be concidered already installed"
echo ""
echo "======================================================================"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

# Installation of jq
# https://github.com/stedolan/jq/releases
if ! [ -x "$(command -v jq)" ]; then
  echo "----------------------------------------------------"
  echo "Installing 'jq' utility ..."
  sudo apt-get update
  sudo apt-get --assume-yes install jq
fi

# Installation of yq
# https://github.com/mikefarah/yq
if ! [ -x "$(command -v yq)" ]; then
  sudo add-apt-repository ppa:rmescandon/yq -y
  sudo apt update
  sudo apt install yq -y
fi

case $DEPLOYMENT in
  eks)
    # AWS CLI
    if ! [ -x "$(command -v aws)" ]; then
      echo "----------------------------------------------------"
      echo "Installing 'aws cli' ..."
      rm -rf awscliv2.zip
      curl --silent "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
    fi
    # kubectl
    if ! [ -x "$(command -v kubectl)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'kubectl' ..."
      curl --silent -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.7/2020-07-08/bin/linux/amd64/kubectl
      echo "Installing 'kubectl' ..."
      chmod +x ./kubectl
      sudo mv ./kubectl /usr/local/bin/kubectl
    fi
    # AWS specific tools
    if ! [ -x "$(command -v aws-iam-authenicator)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'aws-iam-authenticator' ..."
      curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.7/2020-07-08/bin/linux/amd64/aws-iam-authenticator
      echo "Installing 'aws-iam-authenticator' ..."
      chmod +x ./aws-iam-authenticator
      sudo mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator 
    fi
    # eksctl - utility used to provison eks cluster
    if ! [ -x "$(command -v eksctl)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'eksctl' ..."
      rm -rf eksctl*.tar.gz
      rm -rf eksctl
      curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C .
      sudo mv eksctl /usr/local/bin/eksctl
    fi
    ;;
esac

echo ""
echo "===================================================="
echo "Installation complete."
echo "===================================================="

# run a final validation
./validatePrerequisiteTools.sh $DEPLOYMENT

case $DEPLOYMENT in
  eks)
    echo ""
    echo "****************************************************"
    echo "****************************************************"
    echo "If you have not done so already, run this command"
    echo "to configure the aws cli"
    echo ""
    echo "aws configure"
    echo "  enter your AWS Access Key ID"
    echo "  enter your AWS Secret Access Key ID"
    echo "  enter Default region name example us-east-1"
    echo "  Default output format, enter json"
    echo "****************************************************"
    echo "****************************************************"
    ;;
esac

