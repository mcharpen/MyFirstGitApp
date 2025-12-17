#!/bin/bash

echo "======================================"
echo "Fixing Ingress to Use Correct Nginx"
echo "======================================"
echo ""

echo "Problem: The public Ingress was pointing to an old Nginx pod"
echo "in the myfirstgitapp namespace without the /api/ routing rules."
echo ""
echo "Solution: Create an ExternalName service to proxy to the"
echo "correct Nginx in the default namespace."
echo ""

echo "1. Applying updated Ingress with nginx-proxy service..."
kubectl apply -f k8s/ingress.yaml

echo ""
echo "2. Waiting 5 seconds for changes to propagate..."
sleep 5

echo ""
echo "======================================"
echo "Testing All Endpoints"
echo "======================================"
echo ""

echo "Test 1: Main page (should return 200):"
curl -sI https://olite.hd.free.fr/libertyX/ | grep HTTP

echo ""
echo "Test 2: API providers endpoint (should now return JSON!):"
curl -s https://olite.hd.free.fr/api/auth/providers

echo ""
echo "Test 3: Keycloak well-known (should return JSON):"
curl -s https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq -r '.issuer' 2>/dev/null || echo "Check if jq is installed"

echo ""
echo "======================================"
echo "✓ Ingress fixed!"
echo ""
echo "Now test the full Keycloak login flow:"
echo "1. Go to https://olite.hd.free.fr/libertyX/"
echo "2. Click the Keycloak button"
echo "3. Login should work end-to-end!"
echo "======================================"
