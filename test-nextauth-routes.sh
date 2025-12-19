#!/bin/bash

echo "======================================"
echo "Testing Next.js API Routes with basePath"
echo "======================================"
echo ""

echo "1. Testing /libertyX/api/auth/providers (should work)..."
kubectl exec -n myfirstgitapp deployment/frontend -- sh -c 'wget -O- -q "http://localhost:3000/libertyX/api/auth/providers" 2>&1' | jq '.' || echo "Failed"

echo ""
echo ""
echo "2. Testing /libertyX/api/auth/signin..."
kubectl exec -n myfirstgitapp deployment/frontend -- sh -c 'wget -S -O- "http://localhost:3000/libertyX/api/auth/signin" 2>&1 | head -30'

echo ""
echo ""
echo "3. Testing /libertyX/api/auth/csrf..."
kubectl exec -n myfirstgitapp deployment/frontend -- sh -c 'wget -O- -q "http://localhost:3000/libertyX/api/auth/csrf" 2>&1'

echo ""
echo ""
echo "4. Testing different callback URL formats..."
echo ""
echo "a) /libertyX/api/auth/callback/keycloak..."
kubectl exec -n myfirstgitapp deployment/frontend -- sh -c 'wget -S -O- "http://localhost:3000/libertyX/api/auth/callback/keycloak?code=test&state=test" 2>&1 | head -20'

echo ""
echo ""
echo "b) /api/auth/callback/keycloak (without basePath)..."
kubectl exec -n myfirstgitapp deployment/frontend -- sh -c 'wget -S -O- "http://localhost:3000/api/auth/callback/keycloak?code=test&state=test" 2>&1 | head -20'

echo ""
