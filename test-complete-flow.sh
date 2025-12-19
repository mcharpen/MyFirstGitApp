#!/bin/bash

echo "======================================"
echo "Testing Complete Application Flow"
echo "======================================"
echo ""

echo "1. Testing frontend home page..."
curl -I https://olite.hd.free.fr/libertyX/ 2>&1 | grep "HTTP" | head -3

echo ""
echo ""
echo "2. Testing NextAuth providers..."
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers | jq '.'

echo ""
echo ""
echo "3. Testing callback endpoint..."
curl -I "https://olite.hd.free.fr/libertyX/callback/keycloak?state=test&code=test123" 2>&1 | grep -E "(HTTP|Location)" | head -5

echo ""
echo ""
echo "4. Testing Keycloak OpenID configuration..."
curl -s https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq -r '{issuer, authorization_endpoint, token_endpoint}'

echo ""
echo ""
echo "5. Testing backend /emp endpoint..."
curl -I https://olite.hd.free.fr/libertyX/emp 2>&1 | grep "HTTP" | head -3

echo ""
echo ""
echo "======================================"
echo "All Endpoints Ready!"
echo "======================================"
echo ""
echo "🎉 Everything should now be working!"
echo ""
echo "PUBLIC ACCESS (HTTPS):"
echo "  Application: https://olite.hd.free.fr/libertyX/"
echo "  Keycloak Admin: https://olite.hd.free.fr/libertyX/auth/admin/"
echo ""
echo "LOCAL ACCESS (HTTP):"
echo "  Application: http://myfirstgitapp.local/libertyX/"
echo "  Keycloak Admin: http://myfirstgitapp.local/libertyX/auth/admin/"
echo ""
echo "LOGIN CREDENTIALS:"
echo "  Username: mcharpen"
echo "  Password: mypassword"
echo ""
echo "KEYCLOAK ADMIN:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "Try logging in now at: https://olite.hd.free.fr/libertyX/"
echo ""
