#!/bin/bash

echo "======================================"
echo "Debugging NextAuth Configuration"
echo "======================================"
echo ""

echo "1. Checking frontend pod environment variables:"
FRONTEND_POD=$(kubectl get pods -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].metadata.name}')
echo "Pod: $FRONTEND_POD"
echo ""

echo "NextAuth Configuration:"
kubectl exec -n myfirstgitapp $FRONTEND_POD -- env | grep -E "NEXTAUTH|KEYCLOAK" | sort
echo ""

echo "2. Testing NextAuth providers endpoint:"
echo "Internal test:"
kubectl run -n myfirstgitapp test-curl --image=curlimages/curl:latest --rm -i --restart=Never -- curl -s http://frontend.myfirstgitapp.svc.cluster.local:3000/api/auth/providers | head -20
echo ""

echo "External test:"
curl -s https://olite.hd.free.fr/api/auth/providers | head -20
echo ""

echo "3. Testing Keycloak well-known endpoint:"
curl -s https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq -r '.issuer, .authorization_endpoint, .token_endpoint' 2>/dev/null || curl -s https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration | grep -E "issuer|authorization_endpoint|token_endpoint"
echo ""

echo "======================================"
echo "Check if:"
echo "- KEYCLOAK_ISSUER matches the issuer from well-known config"
echo "- NEXTAUTH_URL is set correctly for the public domain"
echo "- NEXTAUTH_SECRET is set"
echo "======================================"
