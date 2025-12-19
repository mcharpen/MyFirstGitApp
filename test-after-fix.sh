#!/bin/bash

echo "======================================"
echo "Waiting for Nginx and Testing"
echo "======================================"
echo ""

echo "1. Waiting for Nginx pod to be ready..."
kubectl wait --for=condition=ready pod -l app=nginx-deployment -n default --timeout=60s || echo "Timeout, checking manually..."

echo ""
echo "2. Checking pod status..."
kubectl get pods -n default -l app=nginx-deployment

echo ""
echo "3. Testing API routes..."
echo ""
echo "a) Testing /api/auth/providers..."
curl -s https://olite.hd.free.fr/api/auth/providers 2>&1 | jq -r '.keycloak.callbackUrl' || echo "Failed"

echo ""
echo ""
echo "b) Testing /api/auth/callback/keycloak..."
curl -I "https://olite.hd.free.fr/api/auth/callback/keycloak?code=test&state=test" 2>&1 | grep -E "(HTTP|Location)" | head -5

echo ""
echo ""
echo "c) Testing frontend home..."
curl -I https://olite.hd.free.fr/libertyX/ 2>&1 | grep "HTTP" | head -2

echo ""
echo ""
echo "======================================"
echo "Testing Complete!"
echo "======================================"
echo ""
echo "The callback URL is now: /api/auth/callback/keycloak"
echo ""
echo "Try logging in at: https://olite.hd.free.fr/libertyX/"
echo ""
