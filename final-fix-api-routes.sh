#!/bin/bash

set -e

echo "======================================"
echo "FINAL FIX: API Routes Don't Use BasePath!"
echo "======================================"
echo ""

echo "Discovery: Next.js basePath doesn't apply to API routes"
echo "Fix: Route /api/ directly to /api/, not /libertyX/api/"
echo ""

echo "1. Applying corrected Nginx ConfigMap..."
kubectl apply -f k8s/nginx-configmap-fixed.yaml

echo ""
echo "2. Restarting Nginx..."
kubectl delete pods -n default -l app=nginx-deployment --force --grace-period=0
sleep 5
kubectl wait --for=condition=ready pod -l app=nginx-deployment -n default --timeout=60s

echo ""
echo "3. Testing API routes..."
echo ""
echo "a) Testing /api/auth/providers..."
curl -s https://olite.hd.free.fr/api/auth/providers | jq -r '.keycloak.callbackUrl'

echo ""
echo ""
echo "b) Testing /api/auth/signin..."
curl -I https://olite.hd.free.fr/api/auth/signin 2>&1 | grep "HTTP" | head -2

echo ""
echo ""
echo "c) Testing callback endpoint..."
curl -I "https://olite.hd.free.fr/api/auth/callback/keycloak?code=test&state=test" 2>&1 | grep -E "(HTTP|Location)" | head -5

echo ""
echo ""
echo "======================================"
echo "Fix Applied!"
echo "======================================"
echo ""
echo "NextAuth callback URL should now be:"
echo "  https://olite.hd.free.fr/api/auth/callback/keycloak"
echo ""
echo "You need to update Keycloak redirect URIs to use /api/auth/callback/keycloak"
echo "instead of /libertyX/api/auth/callback/keycloak"
echo ""
echo "Try logging in at: https://olite.hd.free.fr/libertyX/"
echo ""
