#!/bin/bash

echo "======================================"
echo "Testing Callback Endpoint Routing"
echo "======================================"
echo ""

echo "1. Testing callback endpoint with query parameters..."
echo ""
curl -v "https://olite.hd.free.fr/libertyX/callback/keycloak?state=test&code=test123" 2>&1 | grep -E "(HTTP|Location|< )" | head -20

echo ""
echo ""
echo "2. Testing from inside Nginx pod..."
echo ""
kubectl exec -n default deployment/nginx-deployment -- curl -v "http://localhost/libertyX/callback/keycloak?state=test&code=test123" 2>&1 | grep -E "(HTTP|Location)" | head -10

echo ""
echo ""
echo "3. Testing if frontend can handle the rewritten path..."
echo ""
kubectl exec -n myfirstgitapp deployment/frontend -- wget -q -O- "http://localhost:3000/libertyX/api/auth/callback/keycloak?state=test&code=test" 2>&1 | head -20

echo ""
echo ""
echo "4. Checking Nginx access logs for callback requests..."
echo ""
kubectl exec -n default deployment/nginx-deployment -- tail -50 /var/log/nginx/access.log | grep "/callback/"

echo ""
echo ""
echo "5. Checking Nginx error logs..."
echo ""
kubectl exec -n default deployment/nginx-deployment -- tail -50 /var/log/nginx/error.log | tail -20

echo ""
