#!/bin/bash

set -e

echo "======================================"
echo "Updating Keycloak with correct base path"
echo "======================================"

echo ""
echo "1. Applying updated Keycloak deployment..."
kubectl apply -f k8s/keycloak.yaml

echo ""
echo "2. Waiting for rollout to complete..."
kubectl rollout status deployment/keycloak -n myfirstgitapp --timeout=180s

echo ""
echo "3. Checking pod status..."
kubectl get pods -n myfirstgitapp -l app=keycloak

echo ""
echo "4. Waiting 10 seconds for Keycloak to fully initialize..."
sleep 10

echo ""
echo "5. Testing OpenID configuration endpoint..."
echo ""
curl -s http://myfirstgitapp.local/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq '{issuer, authorization_endpoint, token_endpoint, userinfo_endpoint}' || echo "Failed to fetch OpenID config"

echo ""
echo ""
echo "6. Testing admin console redirect..."
echo ""
curl -I http://myfirstgitapp.local/libertyX/auth/admin/ 2>&1 | grep -E "(HTTP|Location)" || echo "Failed admin console test"

echo ""
echo "======================================"
echo "Update complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Access Keycloak admin at: http://myfirstgitapp.local/libertyX/auth/admin/"
echo "2. Test NextAuth: http://myfirstgitapp.local/libertyX/api/auth/providers"
echo "3. Test login flow: http://myfirstgitapp.local/libertyX/"
echo ""
echo "Expected issuer: http://myfirstgitapp.local/libertyX/auth/realms/myapp"
