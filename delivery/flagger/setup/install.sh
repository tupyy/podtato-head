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

echo "---------------------------------------------------"
echo "Installing Grafana for Flagger..."
echo "---------------------------------------------------"
helm upgrade -i flagger-grafana flagger/grafana --namespace=istio-system --set url=http://prometheus:9090

echo "---------------------------------------------------"
echo "Ask the Slack webhooks to install Slack alerting !"
echo "---------------------------------------------------"
# helm upgrade -i flagger flagger/flagger \
# --set slack.url=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK \
# --set slack.channel=general \
# --set slack.user=flagger