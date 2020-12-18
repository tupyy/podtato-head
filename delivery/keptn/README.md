# Delivering the example using Keptn

_NOTE : you have to be into `delivery/keptn` folder to run the commands below._

## Installing prerequisites

* Install Prerequisites (Kubernetes, Istio)
  * [Tutorial](https://tutorials.keptn.sh/tutorials/keptn-full-tour-prometheus-07/index.html?index=..%2F..index#6) Step 1-7

For your convenience, commands are listed below :

Install Istio (already done)

Install Keptn CLI :

```
curl -sL https://get.keptn.sh | sudo -E bash
keptn version
```

Install Keptn in your cluster (be patient, the installation process will take about 3-5 minutes):

```
keptn install --endpoint-service-type=ClusterIP --use-case=continuous-delivery
```

_WARNING_ : keptn does not seem to handle multiple kubeconfig merged in the KUBECONFIG variable. If you have an error, point you KUBECONFIG var to the kind cluster only : `export KUBECONFIG=/home/guillaume/.kind/config` and relaunch the previous command.

Access Keptn UI :

```
# Port-forward keptn service
kubectl -n keptn port-forward service/api-gateway-nginx 8080:80 &

# Set Keptn authentication
KEPTN_ENDPOINT=http://localhost:8080/api
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)
keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN

# Display Keptn credentials
keptn configure bridge --output
```

You can now login into Keptn portal.

## Deployment

All the keptn configuration is in the `shipyard.yaml` file.

### Create Project

```
./initProject.sh create-project
````

You can see a new project has been created in Keptn UI.
You have also see the 3 environments declared in the `shipyard.yaml` file.

### Onboard Service

```
./initProject.sh onboard-service
````

You can see a service has been onboarded in Keptn UI.

### Deploy Service (new-artifact)

```
./initProject.sh first-deploy-service
````

### Upgrade Service (new-artifact)

```
./initProject.sh upgrade-service
````

Click on the service to see the different deployment stages.
You can see a manual approval is needed : accept to finish the promotion.