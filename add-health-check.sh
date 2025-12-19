#!/bin/bash

set -e

echo "======================================"
echo "Adding Health Check Endpoint"
echo "======================================"
echo ""

echo "1. Applying ConfigMap with /health endpoint..."
kubectl apply -f k8s/nginx-configmap-fixed.yaml

echo ""
echo "2. Patching deployment to use /health for readiness probe..."
kubectl patch deployment nginx-deployment -n default --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/readinessProbe",
    "value": {
      "httpGet": {
        "path": "/health",
        "port": 80
      },
      "initialDelaySeconds": 5,
      "periodSeconds": 10
    }
  }
]'

echo ""
echo "3. Waiting for rollout (this should succeed now)..."
kubectl rollout status deployment/nginx-deployment -n default --timeout=120s

echo ""
echo "4. Checking pod status..."
kubectl get pods -n default | grep nginx

echo ""
echo "5. Testing the application..."
NGINX_POD=$(kubectl get pods -n default -l app=nginx-deployment --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$NGINX_POD" ]; then
  echo "✓ Pod is ready: $NGINX_POD"
  echo ""
  echo "Testing /api/auth/providers..."
  kubectl exec -n default "$NGINX_POD" -- curl -s http://localhost/api/auth/providers | jq -r '.keycloak.callbackUrl'
else
  echo "Waiting for pod to be ready..."
fi

echo ""
echo ""
echo "======================================"
echo "SUCCESS! 🎉"
echo "======================================"
echo ""
echo "Try logging in at: https://olite.hd.free.fr/libertyX/"
echo ""
