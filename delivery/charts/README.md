# Potata Head Helm Chart

_NOTE : you have to be into `delivery/charts` folder to run the commands below._

## Pre Requisites

* Kubernetes 1.9+
* Requires at least Helm v3.0.0

If you do not have Helm 3 installed :

```
./setup/install.sh
```

## Installing the Chart

The chart is currently available via Git in a local directory. To install the
chart first checkout the source code, open a terminal, and move to the `delivery/charts`
sub-directory. Then run

```
helm upgrade --install ph podtatohead -n podtato-helm --create-namespace --wait --timeout 20s
```

This will install the _podtatohead_ chart under the name `hs`.

```
helm ls -n podtato-helm
```

You can view it in your browser:

* either by using `./exposeService.sh`
* or by getting its external IP (if service has been set to 'type=LoadBalancer' in `values.yaml`) :

```
SVC_IP=$(kubectl -n podtato-helm get service ph-podtatohead -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
SVC_PORT=$(kubectl -n podtato-helm get service ph-podtatohead -o jsonpath='{.spec.ports[0].port}')
xdg-open http://${SVC_IP}:${SVC_PORT}
```

The installation can be customized by changing the following paramaters:

| Parameter                       | Description                                                     | Default                      |
| ------------------------------- | ----------------------------------------------------------------| -----------------------------|
| `replicaCount`                  | Number of replicas of the container                             | `1`                          |
| `image.repository`              | Podtato Head Container image name                               | `yogeek/podtatohead`|
| `image.tag`                     | Podtato Head image tag                                          | `v0.1.2`                     |
| `image.pullPolicy`              | Podtato Head Container pull policy                              | `IfNotPresent`               |
| `imagePullSecrets`              | Podtato Head Pod pull secret                                    | ``                           |
| `serviceAccount.create`         | Whether or not to create dedicated service account              | `true`                       |
| `serviceAccount.name`           | Name of the service account to use                              | `default`                    |
| `serviceAccount.annotations`    | Annotations to add to a created service account                 | `{}`                         |
| `podAnnotations`                | Map of annotations to add to the pods                           | `{}`                         |
| `ingress.enabled`               | Enables Ingress                                                 | `false`                      |
| `ingress.annotations`           | Ingress annotations                                             | `{}`                         |
| `ingress.hosts`                 | Ingress accepted hostnames                                      | `[]`                         |
| `ingress.tls`                   | Ingress TLS configuration                                       | `[]`                         |
| `autoscaling.enabled`           | Enable horizontal pod autoscaler                                | `false`                      |
| `autoscaling.targetCPUUtilizationPercentage`  | Target CPU utilization                            | `80`                         |
| `autoscaling.targetMemoryUtilizationPercentage`  | Target Memory utilization                      | `80`                         |
| `autoscaling.minReplicas`       | Min replicas for autoscaling                                    | `1`                          |
| `autoscaling.maxReplicas`       | Max replicas for autoscaling                                    | `100`                        |
| `tolerations`                   | List of node taints to tolerate                                 | `[]`                         |
| `resources`                     | Resource requests and limits                                    | `{}`                         |
| `nodeSelector`                  | Labels for pod assignment                                       | `{}`                         |
| `service.type`                  | Kubernetes Service type                                         | `ClusterIP`                  |
| `service.port`                  | The port the service will use                                   | `9000`                       |

## Updating the version

To update the application version, you can choose one of the following methods :

* run `helm upgrade -i ph podtatohead -n podtato-helm --set image.tag=v0.1.1 --wait --timeout 20s`
* update the `image.tag` value in `values.yaml` (set the value to `v0.1.1`) and run `helm upgrade -i ph podtatohead` again

A new revision is then installed.

Refresh your browser to see the new version !

You can update the revision again in order to have a complete history in the first step.

```
helm upgrade -i ph podtatohead -n podtato-helm --set image.tag=v0.1.2 --wait --timeout 20s
```

## Check revision history

```
helm history ph -n podtato-helm
```

## Rollback to a previous version

To rollback to a previous revision, run :

```
helm rollback ph 1 -n podtato-helm
```

Check the revision

```
helm status ph -n podtato-helm
```

Refresh your browser to see the first version is back.

## Uninstall the chart

```
helm uninstall ph -n podtato-helm
```

## Notes

1. The chart was started by using the command `helm create` and then modified from there
2. The JSON Schema was generated using [this](https://github.com/karuppiah7890/helm-schema-gen) Helm plugin.