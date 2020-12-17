# Delivering the example using a plain manifest

_NOTE : you have to be into `delivery/manifest` folder to run the commands below._

## Deploy

Simply run

```
kubectl apply -f manifest.yaml
```

and this will install a service and a deployment in the ```demospace ``` namespace.

You can then access to the service depending on the Service type :

- if `type=ClusterIP` :

```
kucectl port-forward svc/podtatohead 9000
```

Your app is running at : http://localhost:9000

- if `type=LoadBalancer` (and your service has been allocated an IP) :

```
./getIP.sh
```

## Update

Update the image tag in `manifest.yaml` file and run `kubectl apply -f manifest.yaml` again.

## Delete

```
kubectl delete -f manifest.yaml
```