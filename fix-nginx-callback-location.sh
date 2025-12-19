#!/bin/bash

set -e

echo "======================================"
echo "Fixing Callback Location Matching"
echo "======================================"
echo ""

echo "Issue: Nginx prefix location /libertyX/ was matching before the callback regex"
echo "Fix: Use prefix location /libertyX/callback/ which is more specific"
echo ""

echo "1. Applying fixed Nginx ConfigMap..."
kubectl apply -f k8s/nginx-configmap-fixed.yaml

echo ""
echo "2. Restarting Nginx..."
kubectl rollout restart deployment/nginx-deployment -n default
kubectl rollout status deployment/nginx-deployment -n default --timeout=120s

echo ""
echo "3. Waiting for Nginx to stabilize..."
sleep 5

echo ""
echo "4. Verifying callback location configuration..."
kubectl exec -n default deployment/nginx-deployment -- nginx -T 2>&1 | grep -A 8 "location /libertyX/callback/"

echo ""
echo ""
echo "5. Testing callback endpoint..."
curl -I "https://olite.hd.free.fr/libertyX/callback/keycloak?state=test&code=test123" 2>&1 | grep -E "(HTTP|Location)" | head -5

echo ""
echo ""
echo "6. Testing from inside Nginx pod..."
kubectl exec -n default deployment/nginx-deployment -- curl -I "http://localhost/libertyX/callback/keycloak?state=test&code=test123" 2>&1 | grep "HTTP" | head -3

echo ""
echo ""
echo "======================================"
echo "Fix Applied!"
echo "======================================"
echo ""
echo "Now try the login flow again:"
echo "  https://olite.hd.free.fr/libertyX/"
echo ""
echo "The callback should now be routed correctly from:"
echo "  /libertyX/callback/keycloak → /libertyX/api/auth/callback/keycloak"
echo ""
