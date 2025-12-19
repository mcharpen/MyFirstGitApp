#!/bin/bash

echo "======================================"
echo "Debugging OAuth Callback Flow"
echo "======================================"
echo ""

echo "1. Checking Keycloak realm configuration..."
echo ""
kubectl exec -n myfirstgitapp deployment/keycloak -- curl -s http://localhost:8080/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq -r '{issuer, authorization_endpoint, token_endpoint}' 2>/dev/null || echo "Failed to fetch from Keycloak pod"

echo ""
echo ""
echo "2. Checking NextAuth providers configuration..."
echo ""
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers | jq '.'

echo ""
echo ""
echo "3. Testing callback endpoint..."
echo ""
curl -I https://olite.hd.free.fr/libertyX/api/auth/callback/keycloak 2>&1 | grep -E "(HTTP|Location|Content-Type)" | head -10

echo ""
echo ""
echo "4. Checking Keycloak client configuration..."
echo ""
echo "Expected redirect URIs in Keycloak client:"
echo "  - https://olite.hd.free.fr/libertyX/api/auth/callback/keycloak"
echo "  - https://olite.hd.free.fr/libertyX/*"
echo "  - http://myfirstgitapp.local/libertyX/api/auth/callback/keycloak"
echo "  - http://myfirstgitapp.local/libertyX/*"

echo ""
echo ""
echo "5. Checking frontend logs for errors..."
kubectl logs -n myfirstgitapp deployment/frontend --tail=30 | grep -i -E "(error|callback|auth|keycloak)" || echo "No relevant logs found"

echo ""
echo ""
echo "6. Checking Keycloak logs for callback attempts..."
kubectl logs -n myfirstgitapp deployment/keycloak --tail=50 | grep -i -E "(callback|redirect|error)" || echo "No relevant logs found"

echo ""
echo ""
echo "7. Testing if /libertyX/api/auth/signin/keycloak works..."
echo ""
curl -I https://olite.hd.free.fr/libertyX/api/auth/signin/keycloak 2>&1 | grep -E "(HTTP|Location)" | head -5

echo ""
echo ""
echo "======================================"
echo "Debug Complete"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Check the browser network tab for the exact callback URL"
echo "2. Look for any 404 or error responses"
echo "3. Verify the redirect_uri parameter in the authorization request"
echo ""
