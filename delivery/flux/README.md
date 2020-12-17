# Delivery using [Flux](https://toolkit.fluxcd.io/get-started/)

_NOTE : you have to be into `delivery/flux` folder to run the commands below._

## Install Flux

### Install CLI

```
./setup/install.sh
```

### Install Flux resoures into cluster

Check you cluster :

```
flux check --pre
```

To keep things simple for now, we install Flux in "dev" mode :

```
flux install --arch=amd64

# Note: Flux can also be installed using kubectl
# kubectl apply -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml
```

_Note: In production, it is recommended to use the `bootstrap` mode to ensure the Flux manifests are also synched with a GIT repository._
_cf. "Bootstrap Flux into the cluster" at the end of this file._

## Register Git repositories and reconcile them on your cluster

- [Create a git source](https://toolkit.fluxcd.io/cmd/flux_create_source_git/) pointing to a repository master branch:

```
# Replace by your username to point to YOUR fork of the "podtatohead" project
export GITHUB_USER="yogeek" 

flux create source git podtato \
  --url="https://github.com/${GITHUB_USER}/podtatohead" \
  --branch="training" \
  --interval=1m
```

- [Create a kustomization](https://toolkit.fluxcd.io/cmd/flux_create_kustomization/) for synchronizing manifests on the cluster:

```
flux create kustomization podtato \
  --source=podtato \
  --path="./delivery/manifest" \
  --prune=true \
  --validation=client \
  --health-check="Deployment/podtatohead.demospace" \
  --health-check-timeout=2m
```

- In about 30s the synchronization should start:

```
watch flux get kustomizations
```

- When the synchronization finishes you can check that the webapp services are running:

```
kubectl -n demospace get deployments,services
```

You can see you app with either its service IP (or with port-forward):

```
./getIP.sh
```

Your app is running at : http://[SVC_IP]:9000

From now, any changes made to the Kubernetes manifests in the master branch will be synchronised with the cluster !

- Try to update your source code :

```
# vim delivery/manifest/manifest.yaml
# Update the image version (reminder: existing tags are 0.1.0, 0.1.1, 0.1.2)

# Commit and push your modification
git add -A && git commit -m "update app" && git push 
```

Observe Flux synching your modifications directly into the cluster:

```
watch flux get kustomizations
```

Refresh you app page in the browser !

## Reconciliation details

IMPORTANT :

1. If a Kubernetes manifest is removed from the repository, the reconciler will remove it from your cluster.
2. If you alter the deployment using `kubectl edit`, the changes will be reverted to match the state described in git.
3. If you delete a Kustomization, the reconciler will remove all Kubernetes objects.

## Delete kustomization and source

- Delete the kustomization and see what happens to your resources:

```
flux delete kustomization podtato
```

- Delete the git source :

```
flux delete source git podtato
```

## Register Helm repositories and create Helm releases

FLux can also manage Helm repositories :

```
flux create source helm bitnami \
  --interval=1h \
  --url=https://charts.bitnami.com/bitnami

flux create helmrelease nginx \
  --interval=1h \
  --release-name=nginx-ingress-controller \
  --target-namespace=kube-system \
  --source=HelmRepository/bitnami \
  --chart=nginx-ingress-controller \
  --chart-version="5.x.x"
```

In our case, the cart is in a Git Repository, so we can register a GitRepository source like this :

```
flux create source git podtato-chart \
  --url="https://github.com/${GITHUB_USER}/podtatohead" \
  --branch="training" \
  --interval=1m

flux create helmrelease nginx \
  --interval=1h \
  --release-name=nginx-ingress-controller \
  --target-namespace=kube-system \
  --source=HelmRepository/bitnami \
  --chart=nginx-ingress-controller \
  --chart-version="5.x.x"
```
```

### Bootstrap Flux into the cluster

- Check you cluster :

```
flux check --pre
```

- Create a personnal access token in your github account : https://github.com/settings/tokens

```
export GITHUB_USER=<your_username>
export GITHUB_TOKEN=<your_access_token>
export GITHUB_REPO="podtatohead-flux"
```

- Bootstrap flux with your github repository details :

```
flux bootstrap github \
  --owner="${GITHUB_USER}" \
  --repository=${GITHUB_REPO} \
  --branch=main \
  --path=manifests/flux \
  --personal
```

The bootstrap command creates a repository if one doesn't exist, and commits the manifests for the Flux components to the default branch at the specified path. Then it configures the target cluster to synchronize with the specified path inside the repository.

- Check installation

```
flux check
```

- Clone the repository :

```
git clone https://github.com/${GITHUB_USER}/${GITHUB_REPO}
cd ${GITHUB_REPO}
```

- Create a git source pointing to your repository master branch:

```
flux create source git podtatohead \
  --url=https://github.com/yogeek/podtatohead \
  --branch=master \
  --interval=30s \
  --export > ./manifests/podtatohead/source.yaml
```

- Create a kustomization for synchronizing the manifests on the cluster:

```
flux create kustomization podtatohead \
  --source=podtatohead \
  --path="./delivery/manifest" \
  --prune=true \
  --validation=client \
  --interval=1h \
  --export > ./manifests/podtatohead/resources.yaml
```


## Podinfo app

- Create a git source pointing to a public repository master branch:

```
flux create source git webapp \
  --url=https://github.com/stefanprodan/podinfo \
  --branch=master \
  --interval=30s \
  --export > ./delivery/manifest/webapp-source.yaml
```

- Create a kustomization for synchronizing the common manifests on the cluster:

```
flux create kustomization webapp-common \
  --source=webapp \
  --path="./deploy/webapp/common" \
  --prune=true \
  --validation=client \
  --interval=1h \
  --export > ./delivery/manifest/webapp-common.yaml
```

- Create a kustomization for the backend service that depends on common:

```
flux create kustomization webapp-backend \
  --depends-on=webapp-common \
  --source=webapp \
  --path="./deploy/webapp/backend" \
  --prune=true \
  --validation=client \
  --interval=10m \
  --health-check="Deployment/backend.webapp" \
  --health-check-timeout=2m \
  --export > ./delivery/manifest/webapp-backend.yaml
```

- Create a kustomization for the frontend service that depends on backend:

```
flux create kustomization webapp-frontend \                                               
  --depends-on=webapp-backend \
  --source=webapp \
  --path="./deploy/webapp/frontend" \
  --prune=true \
  --validation=client \
  --interval=10m \
  --health-check="Deployment/frontend.webapp" \
  --health-check-timeout=2m \
  --export > ./delivery/manifest/webapp-frontend.yaml
```

- Push changes to origin:

```
git add -A && git commit -m "add webapp" && git push
```