# Kustomize


https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/

TL;DR

- Kustomize helps customizing config files in a template free way.
- Kustomize provides a number of handy methods like generators to make customization easier.
- Kustomize uses patches to introduce environment specific changes on an already existing standard config file without disturbing it.

## Principles

In some directory containing your YAML resource files (deployments, services, configmaps, etc.), create a `kustomization.yaml` file.
This file should declare those resources, and any customization to apply to them, e.g. add a common label.

Generate customized YAML with: `kustomize build <kustomization_yaml_file_dir>`

Then, you can manage "variants" of a configuration (like development, staging and production) using overlays that modify a common base.

## In pratice

_NOTE : you have to be into `delivery/kustomize` folder to run the commands below._

### Generate manifest from a simple base

```
kustomize build base
```

### Deploy overlays for dev and prod variants

```
kustomize build ./overlays/dev | kubectl apply -f -
```

Check that resources have been created in `dev` namespace with corresponding labels : `kubectl get deploy,svc -n dev --show-labels`

```
kustomize build ./overlays/prod | kubectl apply -f -
```

Check that resources have been created in `prod` namespace with corresponding labels : `kubectl get deploy,svc,hpa -n prod --show-labels`

### Delete

```
kustomize build ./overlays/dev | kubectl delete -f -
kustomize build ./overlays/prod | kubectl delete -f -
```