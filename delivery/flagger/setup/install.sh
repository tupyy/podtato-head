#!/usr/bin/env bash

echo "---------------------------------------------------"
echo "Installing Flagger..."
echo "---------------------------------------------------"
kubectl apply -k github.com/weaveworks/flagger//kustomize/istio
echo

echo "---------------------------------------------------"
echo "Configuring a Gateway..."
echo "---------------------------------------------------"

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: public-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - "*"
EOF