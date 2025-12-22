#!/bin/bash

echo "======================================"
echo "Checking Nginx Deployment Status"
echo "======================================"
echo ""

echo "1. Checking pod status..."
kubectl get pods -n default -l app=nginx-deployment

echo ""
echo ""
echo "2. Checking recent events..."
kubectl get events -n default --sort-by='.lastTimestamp' | tail -20

echo ""
echo ""
echo "3. Checking Nginx logs for errors..."
NGINX_POD=$(kubectl get pods -n default -l app=nginx-deployment -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$NGINX_POD" ]; then
  echo "Logs from pod: $NGINX_POD"
  kubectl logs -n default "$NGINX_POD" --tail=50
else
  echo "No Nginx pod found or pod not running yet"
fi

echo ""
echo ""
echo "4. Testing Nginx configuration syntax..."
kubectl exec -n default deployment/nginx-deployment -- nginx -t 2>&1 || echo "Failed to test config"

echo ""
