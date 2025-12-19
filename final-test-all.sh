#!/bin/bash

echo "======================================"
echo "Waiting for Nginx and Final Test"
echo "======================================"
echo ""

echo "1. Waiting up to 60 seconds for nginx pod to be ready..."
for i in {1..12}; do
  RUNNING_POD=$(kubectl get pods -n default -l app=nginx-deployment --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  if [ -n "$RUNNING_POD" ]; then
    echo "Found running pod: $RUNNING_POD"
    
    # Check if nginx is responding
    if kubectl exec -n default "$RUNNING_POD" -- nginx -t &>/dev/null; then
      echo "✓ Nginx config is valid"
      break
    fi
  fi
  echo "Waiting... ($i/12)"
  sleep 5
done

echo ""
echo "2. Current nginx pods:"
kubectl get pods -n default | grep nginx

echo ""
echo "3. Testing from the running pod..."
RUNNING_POD=$(kubectl get pods -n default -l app=nginx-deployment --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$RUNNING_POD" ]; then
  echo "Using pod: $RUNNING_POD"
  echo ""
  
  echo "a) Testing /api/auth/providers..."
  kubectl exec -n default "$RUNNING_POD" -- curl -s http://localhost/api/auth/providers 2>&1 | jq '.' || echo "Failed or not JSON"
  
  echo ""
  echo "b) Testing /api/auth/callback/keycloak..."
  kubectl exec -n default "$RUNNING_POD" -- curl -I "http://localhost/api/auth/callback/keycloak?code=test&state=test" 2>&1 | grep -E "(HTTP|Location)" | head -5
  
  echo ""
  echo "c) Testing /libertyX/..."
  kubectl exec -n default "$RUNNING_POD" -- curl -I http://localhost/libertyX/ 2>&1 | grep "HTTP" | head -2
else
  echo "No running nginx pod found!"
fi

echo ""
echo "4. Testing from external URL..."
echo ""
echo "a) /api/auth/providers..."
curl -s https://olite.hd.free.fr/api/auth/providers 2>&1 | jq -r '.keycloak.callbackUrl' || echo "Failed"

echo ""
echo "b) /libertyX/..."
curl -I https://olite.hd.free.fr/libertyX/ 2>&1 | grep "HTTP" | head -2

echo ""
echo ""
echo "======================================"
echo "If all tests pass, try logging in at:"
echo "  https://olite.hd.free.fr/libertyX/"
echo "======================================"
echo ""
