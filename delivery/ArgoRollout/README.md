# Delivering the example with a canary release using ArgoCD

_NOTE : you have to be into `delivery/ArgoRollout` folder to run the commands below._

## Install Argo Rollout

You can install [Argo Rollouts](https://argoproj.github.io/argo-rollouts/concepts/#concepts) to your cluster by following the [documentation](https://argoproj.github.io/argo-rollouts/installation/#installation).

For your convenience, the installation commands are given below :

```
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml
```

You can also install the [Argo Rollouts kubectl plugin](https://argoproj.github.io/argo-rollouts/installation/#kubectl-plugin-installation) :

```
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
sudo chmod +x ./kubectl-argo-rollouts-linux-amd64
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
kubectl argo rollouts version
```

## Create a project

```
kubectl create ns demospace-argo
helm install ph-rollout . -n demospace-argo
```

Check resources :

```
kubectl get all -n demospace-argo
kubectl get rollouts.argoproj.io -n demospace-argo
```

A `Rollout` resource has been deployed along with the other resources of the chart.
A copy of the `Rollout` resource is visible at `./sample/rollout.yaml`

## Find our current rollout with the command line

```
kubectl argo rollouts list rollouts -n demospace-argo
```

## Watch the current rollout on the command line

Keep the following command running in a separate terminal to follow the rollout evolution :

```
kubectl argo rollouts get rollout ph-rollout-podtatohead-demo  -w -n demospace-argo
```

## Update the release in the values file

```
helm upgrade ph-rollout . -n demospace-argo --set image.tag=v0.1.2
```

Look at the rollout watched in the other terminal : a canary is started and paused, as defined in the rollout yaml definition.
To continue, you will have to promote it manually on the next step.

## Manually promote the rollout after the first canary steps

```
kubectl argo rollouts promote ph-rollout-podtatohead-demo -n demospace-argo
```

Observe the rollout evolution to progressively switch from the current revision to the new revision, by adjusting the pods in the two replicasets and routing the traffic from one to the other.
Once the rollout is finished, the revision 2 is stable, and the revision 1 is scaled down to 0.

_Note: In a GitOps spirit, our rollout manifest should of course be saved in your git repository to be synchronized by ArgoCD of Flux !_