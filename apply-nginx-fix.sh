#!/bin/bash

set -e

echo "======================================"
echo "Fixing Nginx Keycloak Path"
echo "======================================"

echo ""
echo "1. Applying updated Nginx ConfigMap..."
kubectl apply -f k8s/nginx-default-ns.yaml

echo ""
echo "2. Restarting Nginx to pick up changes..."
kubectl rollout restart deployment/nginx-deployment -n default

echo ""
echo "3. Waiting for rollout..."
kubectl rollout status deployment/nginx-deployment -n default --timeout=60s

echo ""
echo "4. Waiting 5 seconds for Nginx to stabilize..."
sleep 5

echo ""
echo "======================================"
echo "Testing..."
echo "======================================"

echo ""
echo "Testing OpenID configuration:"
echo ""
curl -s http://myfirstgitapp.local/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq -r '.issuer' 2>&1 || echo "Check failed"

echo ""
echo ""
echo "Testing admin console redirect:"
echo ""
curl -I http://myfirstgitapp.local/libertyX/auth/admin/ 2>&1 | head -10

echo ""
echo "======================================"
echo "Done!"
echo "======================================"
