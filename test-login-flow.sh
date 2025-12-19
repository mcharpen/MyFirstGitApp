#!/bin/bash

echo "======================================"
echo "Testing Complete Login Flow"
echo "======================================"
echo ""

echo "LOCAL ACCESS (myfirstgitapp.local):"
echo "-----------------------------------"
echo ""
echo "1. Frontend home page:"
curl -I http://myfirstgitapp.local/libertyX/ 2>&1 | grep -E "(HTTP|Location)" | head -3
echo ""

echo "2. NextAuth signin page:"
curl -I http://myfirstgitapp.local/libertyX/api/auth/signin 2>&1 | grep -E "(HTTP|Location|Content-Type)" | head -5
echo ""

echo "3. Keycloak authorization endpoint (should be reachable):"
curl -I "http://myfirstgitapp.local/libertyX/auth/realms/myapp/protocol/openid-connect/auth?client_id=myapp-client&redirect_uri=http://myfirstgitapp.local/libertyX/api/auth/callback/keycloak&response_type=code&scope=openid" 2>&1 | grep -E "(HTTP|Location|Content-Type)" | head -5
echo ""

echo ""
echo "PUBLIC ACCESS (olite.hd.free.fr):"
echo "-----------------------------------"
echo ""
echo "1. Frontend home page:"
curl -I https://olite.hd.free.fr/libertyX/ 2>&1 | grep -E "(HTTP|Location)" | head -3
echo ""

echo "2. NextAuth providers endpoint:"
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers 2>&1 | jq -r '.keycloak.signinUrl' || echo "Failed to fetch providers"
echo ""

echo "3. Keycloak OpenID configuration:"
curl -s https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration 2>&1 | jq -r '.issuer' || echo "Failed to fetch OpenID config"
echo ""

echo ""
echo "======================================"
echo "Manual Testing Instructions"
echo "======================================"
echo ""
echo "LOCAL:"
echo "  1. Open: http://myfirstgitapp.local/libertyX/"
echo "  2. Click 'Sign in with Keycloak'"
echo "  3. Login with: mcharpen / mypassword"
echo "  4. Should redirect back to app after login"
echo ""
echo "PUBLIC:"
echo "  1. Open: https://olite.hd.free.fr/libertyX/"
echo "  2. Click 'Sign in with Keycloak'"
echo "  3. Login with: mcharpen / mypassword"
echo "  4. Should redirect back to app after login"
echo ""
echo "KEYCLOAK ADMIN:"
echo "  Local:  http://myfirstgitapp.local/libertyX/auth/admin/"
echo "  Public: https://olite.hd.free.fr/libertyX/auth/admin/"
echo "  Login:  admin / admin"
echo ""
