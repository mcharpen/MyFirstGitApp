#!/bin/bash

echo "======================================"
echo "Debugging Frontend Request Handling"
echo "======================================"
echo ""

echo "1. Testing direct access to frontend (bypassing Nginx)..."
echo ""
kubectl exec -n myfirstgitapp deployment/frontend -- sh -c "wget -O- -q http://localhost:3000/libertyX/api/auth/providers 2>&1" | jq '.' || echo "Failed"

echo ""
echo ""
echo "2. Testing what path Next.js expects for API routes..."
echo ""
echo "With basePath='/libertyX', Next.js API routes should be at:"
echo "  - http://localhost:3000/libertyX/api/auth/[...nextauth]"
echo ""

echo "3. Testing different path variations..."
echo ""
echo "a) Testing /libertyX/api/auth/callback/keycloak..."
kubectl exec -n myfirstgitapp deployment/frontend -- sh -c "wget -O- -q 'http://localhost:3000/libertyX/api/auth/callback/keycloak?state=test&code=test' 2>&1" | head -20

echo ""
echo ""
echo "b) Testing /api/auth/callback/keycloak (without basePath)..."
kubectl exec -n myfirstgitapp deployment/frontend -- sh -c "wget -O- -q 'http://localhost:3000/api/auth/callback/keycloak?state=test&code=test' 2>&1" | head -20

echo ""
echo ""
echo "4. Checking frontend logs..."
kubectl logs -n myfirstgitapp deployment/frontend --tail=30

echo ""
