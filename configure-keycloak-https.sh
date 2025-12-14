#!/bin/bash

set -e

echo "======================================"
echo "Configuring Keycloak for Public HTTPS Access"
echo "======================================"
echo ""

echo "Changes:"
echo "  - Set KC_HOSTNAME_URL to https://olite.hd.free.fr/libertyX/auth"
echo "  - Set KC_PROXY to 'edge' for HTTPS termination"
echo "  - Update frontend KEYCLOAK_ISSUER to match public URL"
echo ""

echo "1. Applying updated Keycloak deployment..."
kubectl apply -f k8s/keycloak.yaml

echo ""
echo "2. Applying updated frontend deployment..."
kubectl apply -f k8s/frontend.yaml

echo ""
echo "3. Waiting for Keycloak rollout..."
kubectl rollout status deployment/keycloak -n myfirstgitapp --timeout=180s

echo ""
echo "4. Waiting for frontend rollout..."
kubectl rollout status deployment/frontend -n myfirstgitapp --timeout=180s

echo ""
echo "5. Waiting 10 seconds for services to initialize..."
sleep 10

echo ""
echo "6. Testing OpenID configuration (via public URL)..."
echo ""
curl -s https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq -r '{issuer, authorization_endpoint, token_endpoint}' || echo "Failed to fetch"

echo ""
echo ""
echo "7. Testing NextAuth providers (via public URL)..."
echo ""
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers | jq '.' || echo "Failed to fetch"

echo ""
echo ""
echo "8. Testing local access OpenID configuration..."
echo ""
curl -s http://myfirstgitapp.local/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq -r '{issuer, authorization_endpoint}' || echo "Failed to fetch"

echo ""
echo ""
echo "======================================"
echo "Configuration Complete!"
echo "======================================"
echo ""
echo "Now test the login flow:"
echo ""
echo "PUBLIC (HTTPS): https://olite.hd.free.fr/libertyX/"
echo "LOCAL (HTTP):   http://myfirstgitapp.local/libertyX/"
echo ""
echo "Login with: mcharpen / mypassword"
echo ""
echo "Note: The issuer and all OAuth URLs should now show https://olite.hd.free.fr/libertyX/auth"
echo ""
