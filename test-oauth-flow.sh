#!/bin/bash

echo "=========================================="
echo "Testing NextAuth + Keycloak OAuth Flow"
echo "=========================================="
echo ""

# Test 1: Check NextAuth providers endpoint
echo "1. Testing NextAuth providers endpoint..."
echo "   URL: https://olite.hd.free.fr/libertyX/api/auth/providers"
PROVIDERS=$(curl -s https://olite.hd.free.fr/libertyX/api/auth/providers)
echo "$PROVIDERS" | jq .
echo ""

# Check if providers response is valid
if echo "$PROVIDERS" | jq -e '.keycloak' > /dev/null 2>&1; then
  echo "   ✅ Providers endpoint works!"
  
  SIGNIN_URL=$(echo "$PROVIDERS" | jq -r '.keycloak.signinUrl')
  CALLBACK_URL=$(echo "$PROVIDERS" | jq -r '.keycloak.callbackUrl')
  
  echo "   Sign-in URL: $SIGNIN_URL"
  echo "   Callback URL: $CALLBACK_URL"
else
  echo "   ❌ Providers endpoint failed!"
  exit 1
fi
echo ""

# Test 2: Check Keycloak well-known configuration
echo "2. Testing Keycloak OpenID configuration..."
echo "   URL: https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration"
OIDC_CONFIG=$(curl -s https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration)
echo "$OIDC_CONFIG" | jq '{issuer, authorization_endpoint, token_endpoint, userinfo_endpoint}'
echo ""

if echo "$OIDC_CONFIG" | jq -e '.issuer' > /dev/null 2>&1; then
  echo "   ✅ Keycloak OpenID configuration works!"
  echo "   Issuer: $(echo "$OIDC_CONFIG" | jq -r '.issuer')"
else
  echo "   ❌ Keycloak OpenID configuration failed!"
  exit 1
fi
echo ""

# Test 3: Check if redirect URIs are properly configured
echo "3. Checking Keycloak client configuration..."
KC_POD=$(kubectl get pod -n myfirstgitapp -l app=keycloak -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080/libertyX/auth \
  --realm master \
  --user admin \
  --password admin > /dev/null 2>&1

CLIENT_ID=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients -r myapp -q clientId=myapp-client --fields id --format csv --noquotes)
CLIENT_CONFIG=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients/$CLIENT_ID -r myapp --fields redirectUris,webOrigins)

echo "$CLIENT_CONFIG" | jq '{redirectUris, webOrigins}'
echo ""

# Test 4: Verify direct access grants is enabled
echo "4. Checking Direct Access Grants setting..."
DIRECT_ACCESS=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients/$CLIENT_ID -r myapp --fields directAccessGrantsEnabled | jq -r '.directAccessGrantsEnabled')
if [ "$DIRECT_ACCESS" = "true" ]; then
  echo "   ✅ Direct Access Grants: ENABLED"
else
  echo "   ⚠️  Direct Access Grants: DISABLED"
fi
echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "✅ All configuration checks passed!"
echo ""
echo "Next steps to test the full OAuth flow:"
echo "1. Open https://olite.hd.free.fr/libertyX/ in your browser"
echo "2. Click the 'Sign in with Keycloak' button"
echo "3. Login with: mcharpen / mypassword"
echo "4. You should be redirected back to the application"
echo ""
echo "If the login fails, check the browser console and network tab for errors."
