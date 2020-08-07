# Overview

This repos has the code and scripts to provision and configure a cloud infrastructure running Kubernetes and the [Dynatrace OneAgent Operator](https://www.dynatrace.com/support/help/technology-support/cloud-platforms/kubernetes/deploy-oneagent-k8/) from a Linux host.

Currently, these setup scripts support only Amazon EKS using [ekscli for Amazon EKS](https://eksctl.io/) from a Linux EC2 instance.

Use cases:
* Have an environment that can be used for demos with Dynatrace. 
* Have an environment that can be used for demos with https://keptn.sh

# Pre-requisites

## 1. Accounts

1. Dynatrace - Assumes you will use a trial SaaS dynatrace tenant from https://www.dynatrace.com/trial and create a PaaS and API token
1. Cloud provider account.  Highly recommend to sign up for personal free trial as to have full admin rights and to not cause any issues with your enterprise account. Links to free trials
   * AWS - https://aws.amazon.com/free/

## 2. Bastion host setup

See these instructions for provisioning a Linux host on the targeted cloud provider.
* [AWS EC2 instance](AWS.md) 

# Provision Cluster

SSH into the bastion host and follow these steps for the setup.

NOTE: There are multiple scripts used for the setup and they must be run the right order.  Just run the setup script that will prompt you with menu choices.
```
./setup.sh <deployment type>
```
NOTE: Valid 'deployment type' argument values are:
* eks = AWS

NOTE: The ```setup.sh``` script will set your 'deployment type' selection into creds.json file so that you don't have to keep typing it in each time.

The setup menu should look like this:
```
====================================================
SETUP MENU
====================================================
1)  Install Prerequisites Tools
2)  Enter Installation Script Inputs
3)  Provision Kubernetes cluster
4)  Perform Setup
----------------------------------------------------
10)  Validate Kubectl
11)  Validate Prerequisite Tools
12)  Show Dynatrace Pods
----------------------------------------------------
99) Delete Kubernetes cluster
====================================================
Please enter your choice or <q> or <return> to exit

```

NOTE: each script will log the console output into the ```logs/``` subfolder.

## 1) Install Prerequisites Tools

The following set of tools will be installed by the installation script and will be available for interacting with the environment.

All platforms
* jq - [Json query utility to suport parsing](https://stedolan.github.io/jq/)
* yq - [Yaml query utility to suport parsing](https://github.com/mikefarah/yq)
* kubectl - [CLI to manage the cluster](https://kubernetes.io/docs/tasks/tools/install-kubectl). This is required for all, but will use the installation instructions per each cloud provider

AWS additional tools
* aws - [CLI for AWS](https://aws.amazon.com/cli/)
* ekscli - [CLI for Amazon EKS](https://eksctl.io/)
* aws-iam-authenticator - [Provides authentication kubectl to the eks cluster](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

At the end if the installation, the Sscript will call the 'Validate Prerequisite Tools' script that will verify tools setup setup.  

You can re-run both 'Install Prerequisites Tools' or 'Validate Prerequisite Tools' anytime as required.

## 2) Enter Installation Script Inputs

Before you do this step, be prepared with your github credentials, dynatrace tokens, and cloud provider project information available.

This will prompt you for values that are referenced in the remaining setup scripts. Inputted values are stored in ```creds.json``` file.  

## 3) Provision Kubernetes cluster

This will provision a Cluster on the specified cloud deployment type. This script will take several minutes to run and you can verify the cluster was created with the the cloud provider console.

This script at the end will run the 'Validate Kubectl' script mentioned below.

## 4) Setup Dynatrace

This script will use the Dynatrace URL and tokens from the 'Enter Installation Script Inputs' step to install the [Dynatrace OneAgent Operator](https://www.dynatrace.com/support/help/technology-support/cloud-platforms/kubernetes/deploy-oneagent-k8/)

# Other setup related scripts

These are additional scripts available in the 'setup.sh' menu/

## 10)  Validate Kubectl

This script will attempt to 'get pods' using kubectl.  If kubectl can connect to the cluster, this script will pass.

## 11)  Validate Prerequisite Tools

This script will look for the existence of required prerequisite tools.  It does NOT check for version just the existence of the script. 

## 12)  Show Dynatrace Pods

This script will output the Pods in the Dynatrace namespace

## 99) Remove Kubernetes cluster

Fastest way to remove everything is to delete your cluster using this script.  Becare when you run this as to not lose your work.

NOTE: ekscli will report that the delete is done, but review the AWS console too. It seems it takes longer for the eks cluster and the cloudformation script that ekscli creates to actaully be deleted.


# Delete everything

SSH into the bastion Linux host and run the `./setup/sh` script and choose the option `99) Remove Kubernetes cluster`

From the AWS console, terminate the Bastion Linux host.