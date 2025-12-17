#!/bin/bash

echo "======================================"
echo "Fixing Nginx Readiness Probe"
echo "======================================"
echo ""

echo "1. Getting current deployment definition..."
kubectl get deployment nginx-deployment -n default -o yaml > /tmp/nginx-deployment-current.yaml

echo ""
echo "2. Checking for readiness probe..."
grep -A 5 "readinessProbe" /tmp/nginx-deployment-current.yaml || echo "No readiness probe found in YAML export"

echo ""
echo "3. Patching deployment to use /libertyX/ for readiness probe..."
kubectl patch deployment nginx-deployment -n default --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/readinessProbe",
    "value": {
      "httpGet": {
        "path": "/libertyX/",
        "port": 80
      },
      "initialDelaySeconds": 5,
      "periodSeconds": 10
    }
  }
]'

echo ""
echo "4. Waiting for rollout..."
kubectl rollout status deployment/nginx-deployment -n default --timeout=120s

echo ""
echo "5. Checking pod status..."
kubectl get pods -n default | grep nginx

echo ""
echo "6. Testing endpoints..."
sleep 5
NGINX_POD=$(kubectl get pods -n default -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}' | grep nginx | head -1)
if [ -n "$NGINX_POD" ]; then
  echo "Testing with pod: $NGINX_POD"
  kubectl exec -n default "$NGINX_POD" -- curl -s http://localhost/api/auth/providers | jq '.' || echo "Failed"
else
  echo "No ready pod found yet"
fi

echo ""
