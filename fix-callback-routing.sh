#!/bin/bash

set -e

echo "======================================"
echo "Fixing OAuth Callback Routing"
echo "======================================"
echo ""

echo "Changes:"
echo "  1. Add Nginx location to route /libertyX/callback/* to /libertyX/api/auth/callback/*"
echo "  2. Add /libertyX/callback/keycloak to Keycloak redirect URIs"
echo "  3. Restart services to apply changes"
echo ""

echo "1. Applying fixed Nginx ConfigMap..."
kubectl apply -f k8s/nginx-configmap-fixed.yaml

echo ""
echo "2. Applying updated Keycloak realm config..."
kubectl apply -f k8s/keycloak.yaml

echo ""
echo "3. Restarting Nginx..."
kubectl rollout restart deployment/nginx-deployment -n default
kubectl rollout status deployment/nginx-deployment -n default --timeout=120s

echo ""
echo "4. Restarting Keycloak to reload realm..."
kubectl rollout restart deployment/keycloak -n myfirstgitapp
kubectl rollout status deployment/keycloak -n myfirstgitapp --timeout=180s

echo ""
echo "5. Waiting for services to stabilize..."
sleep 10

echo ""
echo "6. Testing callback routing..."
echo ""
echo "Testing /libertyX/callback/keycloak endpoint:"
curl -I https://olite.hd.free.fr/libertyX/callback/keycloak 2>&1 | grep -E "(HTTP|Location)" | head -5

echo ""
echo ""
echo "======================================"
echo "Fix Applied!"
echo "======================================"
echo ""
echo "Now try the login flow again:"
echo "  https://olite.hd.free.fr/libertyX/"
echo ""
echo "The callback URL /libertyX/callback/keycloak will now be routed to"
echo "the correct NextAuth endpoint at /libertyX/api/auth/callback/keycloak"
echo ""
