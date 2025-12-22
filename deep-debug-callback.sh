#!/bin/bash

echo "======================================"
echo "Deep Debugging Callback 404"
echo "======================================"
echo ""

echo "1. Checking exact Nginx configuration for callback..."
kubectl exec -n default deployment/nginx-deployment -- nginx -T 2>&1 | grep -B 2 -A 12 "location /libertyX/callback/"

echo ""
echo ""
echo "2. Testing callback from inside Nginx pod with verbose output..."
kubectl exec -n default deployment/nginx-deployment -- sh -c 'curl -v "http://localhost/libertyX/callback/keycloak?state=test&code=test" 2>&1 | head -50'

echo ""
echo ""
echo "3. Checking what URL is actually being proxied to frontend..."
kubectl exec -n default deployment/nginx-deployment -- tail -20 /var/log/nginx/access.log | grep callback

echo ""
echo ""
echo "4. Testing direct access to frontend callback endpoint..."
kubectl exec -n myfirstgitapp deployment/frontend -- sh -c 'wget -O- "http://localhost:3000/libertyX/api/auth/callback/keycloak?state=test&code=test" 2>&1' | head -30

echo ""
echo ""
echo "5. Checking Nginx error logs for upstream errors..."
kubectl exec -n default deployment/nginx-deployment -- tail -50 /var/log/nginx/error.log | tail -20

echo ""
