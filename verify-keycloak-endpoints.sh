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
echo "5. Checking Nginx logs for recent /libertyX/auth requests:"
kubectl exec -n default deployment/nginx-deployment -- tail -20 /var/log/nginx/access.log | grep "/libertyX/auth"

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
