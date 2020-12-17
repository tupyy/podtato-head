SVC_IP=$(kubectl get service podtatohead -n demospace -ojsonpath='{.status.loadBalancer.ingress[0].ip}')
SVC_PORT=$(kubectl get service podtatohead -n demospace -o jsonpath='{.spec.ports[0].port}')
echo "http://${SVC_IP}:${SVC_PORT}"