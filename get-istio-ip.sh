#!/bin/bash

unset ISTIO_HOST

while [[ "$ISTIO_HOST" = "" ]]; do
  export ISTIO_HOST=$(kubectl --namespace istio-system get svc istio-ingressgateway --output jsonpath="{.status.loadBalancer.ingress[0].ip}")
  sleep 1
done

echo $ISTIO_HOST
