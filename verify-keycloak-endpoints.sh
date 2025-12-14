#!/bin/bash

echo "======================================"
echo "Verifying Keycloak Endpoints"
echo "======================================"

echo ""
echo "1. Testing OpenID Configuration (should have /libertyX/auth in all URLs):"
echo ""
curl -s http://myfirstgitapp.local/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq '{
  issuer,
  authorization_endpoint,
  token_endpoint,
  userinfo_endpoint,
  end_session_endpoint
}'

echo ""
echo ""
echo "2. Testing Admin Console Access:"
echo ""
curl -I http://myfirstgitapp.local/libertyX/auth/admin/ 2>&1 | head -15

echo ""
echo ""
echo "3. Testing Keycloak Root (should redirect):"
echo ""
curl -I http://myfirstgitapp.local/libertyX/auth/ 2>&1 | head -10

echo ""
echo ""
echo "4. Testing NextAuth Providers Endpoint:"
echo ""
curl -s http://myfirstgitapp.local/libertyX/api/auth/providers | jq '.'

echo ""
echo ""
echo "5. Testing Direct Keycloak Service (from inside cluster):"
echo ""
kubectl run test-kc-path --image=curlimages/curl --rm -i --restart=Never -- \
  sh -c "curl -s http://keycloak.myfirstgitapp.svc.cluster.local:8080/libertyX/auth/realms/myapp/.well-known/openid-configuration 2>&1 | head -5"

echo ""
echo ""
echo "======================================"
echo "Verification Complete!"
echo "======================================"
echo ""
echo "Next steps to test authentication:"
echo "1. Open browser: http://myfirstgitapp.local/libertyX/"
echo "2. Click 'Sign In' button"
echo "3. Should redirect to Keycloak login at /libertyX/auth/realms/myapp/..."
echo "4. After login, should redirect back to /libertyX/"
