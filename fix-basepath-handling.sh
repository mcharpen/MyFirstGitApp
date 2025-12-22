#!/bin/bash

set -e

echo "======================================"
echo "CRITICAL FIX: Frontend BasePath Handling"
echo "======================================"
echo ""

echo "Issue: Next.js basePath='/libertyX' but Nginx was stripping it"
echo "Fix: Change proxy_pass to include /libertyX/ path"
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
echo "4. Testing frontend home page..."
curl -I https://olite.hd.free.fr/libertyX/ 2>&1 | grep "HTTP" | head -3

echo ""
echo ""
echo "5. Testing callback endpoint..."
curl -I "https://olite.hd.free.fr/libertyX/callback/keycloak?state=test&code=test123" 2>&1 | grep "HTTP" | head -3

echo ""
echo ""
echo "6. Testing API providers endpoint..."
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers | jq -r '.keycloak.id' || echo "Failed"

echo ""
echo ""
echo "======================================"
echo "Fix Applied!"
echo "======================================"
echo ""
echo "Now ALL requests to /libertyX/* will be forwarded WITH the basePath to Next.js"
echo ""
echo "Try the login flow again:"
echo "  https://olite.hd.free.fr/libertyX/"
echo ""
