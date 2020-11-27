#!/bin/bash

unset INGRESS_HOST

while [[ "$INGRESS_HOST" = "" ]]; do
  export INGRESS_HOST=$(kubectl --namespace ingress-nginx get svc ingress-nginx-controller --output jsonpath="{.status.loadBalancer.ingress[0].ip}")
  sleep 1
done

echo $INGRESS_HOST
