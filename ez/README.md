# Overview

These scripts allow to start easyTravel using docker images on kubernetes. 

This setup includes the following pods that will be deployed into a `easytravel` namespace
- easytravel-frontend
- easytravel-backend
- easytravel-mongodb (backend database)
- easytravel-loadgen (traffic generator)

The images used are the public ones published by Dynatrace found in [Dockerhub](https://hub.docker.com/search?q=dynatrace%2Feasytravel&type=image
)

For addition details on the EasyTravel application see this [EasyTravel Docker README](https://github.com/Dynatrace/easyTravel-Docker)

# Prerequisites:

1. Kubernetes cluster.
1. Machine with the tool "kubectl" installed - https://kubernetes.io/docs/tasks/tools/install-kubectl/

# Usage

1. The first script to run should be "./setup.sh". This runs the `kubectl` commands to for installing EasyTravel and after a waiting period the load generator service
1. Once finished you can remove the services with "./delete.sh" script.

# Open the Web UI

Run these commands to get the frontend URL to open in a browser

```
echo "http://$(kubectl describe svc easytravel-frontend -n easytravel | grep "LoadBalancer Ingress:" | sed 's/LoadBalancer Ingress:[ \t]*//'):8080" 
```

For example on AWS EKS cluster, the result would look like this:

http://aa2f6cef1d42145lkajsdflkajdfsklads-974639444.us-west-2.elb.amazonaws.com:8080

# Enabling Problem Patterns

Valid problems are:
* BadCacheSynchronization,CPULoad,DatabaseCleanup,DatabaseSlowdown,FetchSizeTooSmall
* JourneySearchError404,JourneySearchError500,LoginProblems,MobileErrors,TravellersOptionBox

To enable a problem, paste the following URLs in a browser or Postman as GET requests

```
# adjust PROBLEM_PATTERN for your usecase based on valid values above
export PROBLEM_PATTERN=LoginProblems

export BACKEND_URL=$(kubectl describe svc easytravel-backend -n easytravel | grep "LoadBalancer Ingress:" | sed 's/LoadBalancer Ingress:[ \t]*//') 

echo "http://$BACKEND_URL:8080/services/ConfigurationService/setPluginEnabled?name=$PROBLEM_PATTERN&enabled=true"
echo "http://$BACKEND_URL:8080/services/ConfigurationService/getEnabledPluginNames"
```

For example on AWS EKS cluster, the result would look like this:

http://a96cbed3-14682dasdfkasdfad79163.us-west-2.elb.amazonaws.com:8080/services/ConfigurationService/setPluginEnabled?name=LoginProblems&enabled=true

http://a96cbed3-14682dasdfkasdfad79163.us-west-2.elb.amazonaws.com:8080/services/ConfigurationService/getEnabledPluginNames

getEnabledPluginNames output looks like this:

```
<ns:getEnabledPluginNamesResponse xmlns:ns="http://webservice.business.easytravel.dynatrace.com">
<ns:return>DummyNativeApplication</ns:return>
<ns:return>DummyNativeApplication.NET</ns:return>
<ns:return>DummyPaymentService</ns:return>
<ns:return>LoginProblems</ns:return>
</ns:getEnabledPluginNamesResponse>
```