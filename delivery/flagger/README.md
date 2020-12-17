# Progressive Delivery with Flagger and Istio

https://docs.flagger.app/tutorials/istio-progressive-delivery

## Installation

_NOTE : you have to be into `delivery/flagger` folder to run the commands below._

### Install Istio

Istio should have been installed in the SETUP.md steps.

```
istioctl verify-install
```

### Install Flagger

```
./setup/install.sh
```

## Deploy app

- Create a test namespace with Istio sidecar injection enabled:

```
kubectl create ns test
kubectl label namespace test istio-injection=enabled
```

- Create a deployment and a horizontal pod autoscaler:

```
kubectl apply -k github.com/weaveworks/flagger//kustomize/podinfo
```

- Deploy the load testing service to generate traffic during the canary analysis:

```
kubectl apply -k github.com/weaveworks/flagger//kustomize/tester
```

- Check resources:

```
kubectl get deploy,svc,hpa -n test
```

- Create a canary custom resource:

```
kubectl apply -f ./podinfo-canary.yaml
```

When the canary analysis starts, Flagger will call the pre-rollout webhooks before routing traffic to the canary.
The canary analysis will run for five minutes while validating the HTTP metrics and rollout hooks every minute.

After a couple of seconds Flagger will create the canary objects:

```
kubectl get deploy,svc,hpa,canary,virtualservices,destinationrules -n test
```

Wait for the canary status to become `Initialized`.

- Trigger a canary deployment by updating the container image:

```
kubectl -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.1
```

Flagger detects that the deployment revision changed and starts a new rollout:

```
watch 'kubectl -n test describe canary/podinfo | tail -30'
```

_Note_ : if you apply new changes to the deployment during the canary analysis, Flagger will restart the analysis.

A canary deployment is triggered by changes in any of the following objects:
- Deployment PodSpec (container image, command, ports, env, resources, etc)
- ConfigMaps mounted as volumes or mapped to environment variables
- Secrets mounted as volumes or mapped to environment variables

You can monitor all canaries with:

```
watch kubectl get canaries --all-namespaces
```

You can also follow the canary evolution interactively in Kiali:

```
kubectl port-forward svc/kiali 20001 -n istio-system
```

And a grafana dashboard is also available for Istio Canary :

```
kubectl port-forward svc/flagger-grafana -n istio-system 8888:80
```

## Automated rollback

During the canary analysis you can generate HTTP 500 errors and high latency to test if Flagger pauses the rollout.

Trigger another canary deployment:

```
kubectl -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.2
```

Generate HTTP 500 errors by connecting into the load tester pod:

```
POD_NAME=$(kubectl get po -n test -l app=flagger-loadtester -o name)
kubectl -n test exec -it ${POD_NAME} -- watch curl http://podinfo-canary:9898/status/500
```

In another terminal, generate latency by connecting into the load tester pod:

```
POD_NAME=$(kubectl get po -n test -l app=flagger-loadtester -o name)
kubectl -n test exec -it ${POD_NAME} -- watch curl http://podinfo-canary:9898/delay/1
```

When the number of failed checks reaches the canary analysis threshold, the traffic is routed back to the primary. 
The canary is scaled to zero and the rollout is marked as failed.

```
kubectl -n test describe canary/podinfo
# Rolling back podinfo.test failed checks threshold reached 5
# Canary failed! Scaling down podinfo.test
```

## Progressive Delivery strategies

To see what are the different deployment strategies and how they are managed by Flagger :
https://docs.flagger.app/usage/deployment-strategies