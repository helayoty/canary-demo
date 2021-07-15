# Canary Deployments with NGINX Ingress Controller
## Overview
This repository contains all resources that are required to test the canary feature of NGINX Ingress Controller. 

## Requirements
* Kubernetes cluster 
* NGINX Ingress Controller 0.21.0+

```bash
helm install nginx-ingress ingress-nginx/ingress-nginx     --namespace ingress-nginx  --set controller.replicaCount=2     --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux     --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux     --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux --set controller.metrics.enabled=true --set-string controller.podAnnotations."prometheus\.io/scrape"="true" --set-string controller.podAnnotations."prometheus\.io/port"="10254"
```

## Getting Started

### Canary Test Scenario
##### Prepare Manifests  
First of all, change the host definition in the ingress manifests ***deploy/prod-ingress.yaml*** and ***deploy/canary-ingress.yaml*** from canary-demo.example.com to your URL
  
##### Deploy production release  
Roll-out the stable version 1.0.0 to the cluster
```bash
$ make step-1
```
  
##### Run tests  
Execute the following commands to send n=1000 requests to the endpoint
```bash
$ ab -n 1000 -c 100 -s 60 -m GET -H "HOST: <YOU_HOST>" "http://<your_URL>/version"
$ curl -s -H 'HOST: <YOU_HOST>' "http://<your_URL>/metrics" | jq '.calls'
```
If everything is working as expected, the curl command should return "1000".
  
##### Reset request counter  
Send GET requests to /reset endpoint to set the request counter to zero
```bash
$ curl -H 'HOST: <YOU_HOST>' "http://<your_URL>/reset"
```
  
##### Canary deployment  
Push the new software version 1.0.1 as a canary deployment to the cluster
```bash
$ make step-2
```
  
##### Perform tests  
Again, start sending traffic to the endpoint
```bash
$ ab -n 1000 -c 100 -s 60 GET -H "HOST: <YOU_HOST>" "http://<your_URL>/version"
```
  
##### Verify the weight split 

```bash
$ curl -s -H 'HOST: <YOU_HOST>' http://<YOUR_INGRESS)EXTERNAL_IP>/metrics | jq '.calls'
$ curl -s -H 'HOST: <YOU_HOST>' http://<YOUR_INGRESS)EXTERNAL_IP>/metrics | jq '.calls'
```

Unless the weight has been changed to a different value, you should see approximately 500 requests being served by the production deployment and the remainig 500 by the canary. 

##### Verify the weight split with prometheus and grafana

Install prometheus & grafana by following the instructions [here](https://kubernetes.github.io/ingress-nginx/user-guide/monitoring/)



![nginx-ingress-controller](/.images/nginx-ingress-controller.png)
![request-handling-performance](/.images/request-handling-performance.png)

### Clean-up
Remove all resource from the cluster 
```bash
$ make clean-up
```
