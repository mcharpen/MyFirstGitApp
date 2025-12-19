#!/bin/bash

set -e

echo "======================================"
echo "Updating Frontend with Correct Keycloak Issuer"
echo "======================================"
echo ""

echo "1. Applying updated frontend deployment..."
kubectl apply -f k8s/frontend.yaml

echo ""
echo "2. Waiting for rollout to complete..."
kubectl rollout status deployment/frontend -n myfirstgitapp --timeout=180s

echo ""
echo "3. Waiting 5 seconds for frontend to initialize..."
sleep 5

echo ""
echo "4. Testing NextAuth providers endpoint..."
echo ""
curl -s http://myfirstgitapp.local/libertyX/api/auth/providers | jq '.'

echo ""
echo ""
echo "5. Testing NextAuth signin endpoint..."
curl -I http://myfirstgitapp.local/libertyX/api/auth/signin 2>&1 | grep -E "(HTTP|Location|Content-Type)" | head -5

echo ""
echo ""
echo "======================================"
echo "Update Complete!"
echo "======================================"
echo ""
echo "You can now test the login flow:"
echo ""
echo "LOCAL: http://myfirstgitapp.local/libertyX/"
echo "PUBLIC: https://olite.hd.free.fr/libertyX/"
echo ""
echo "Login credentials:"
echo "  Username: mcharpen"
echo "  Password: mypassword"
echo ""
echo "Keycloak Admin Console:"
echo "  LOCAL: http://myfirstgitapp.local/libertyX/auth/admin/"
echo "  Username: admin"
echo "  Password: admin"
echo ""
