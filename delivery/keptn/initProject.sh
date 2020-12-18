#!/usr/bin/env bash

PROJECT="pod-tato-head"
IMAGE="tupyy/podtatohead"
VERSION="$2"

case "$1" in
  "create-project")
    echo "Creating keptn project $PROJECT"
    echo keptn create project "${PROJECT}" --shipyard=./shipyard.yaml   
    keptn create project "${PROJECT}" --shipyard=./shipyard.yaml
    ;;
  "onboard-service")
    echo "Onboarding keptn service podtatohead in project ${PROJECT}"
    keptn onboard service podtatohead --project="${PROJECT}" --chart=helm-charts/podtatohead
    ;;
  "first-deploy-service")
    echo "Deploying keptn service podtatohead in project ${PROJECT}"
    keptn send event new-artifact --project="${PROJECT}" --service=podtatohead --image="${IMAGE}" --tag=v0.1.1
    ;;
  "deploy-service")
    echo "Deploying keptn service podtatohead in project ${PROJECT}"
    echo keptn send event new-artifact --project="${PROJECT}" --service=podtatohead --image="${IMAGE}" --tag=v"${VERSION}"
    keptn send event new-artifact --project="${PROJECT}" --service=podtatohead --image="${IMAGE}" --tag=v"${VERSION}"
    ;;    
  "upgrade-service")
    echo "Upgrading keptn service podtatohead in project ${PROJECT}"
    keptn send event new-artifact --project="${PROJECT}" --service=podtatohead --image="${IMAGE}" --tag=v0.1.2
    ;;
esac