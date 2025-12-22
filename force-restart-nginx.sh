#!/bin/bash

echo "======================================"
echo "Force Restarting Nginx Deployment"
echo "======================================"
echo ""

echo "1. Checking current pod status..."
kubectl get pods -n default -l app=nginx-deployment

echo ""
echo "2. Deleting old Nginx pods..."
kubectl delete pods -n default -l app=nginx-deployment --grace-period=0 --force 2>&1 || echo "No pods to delete or already deleted"

echo ""
echo "3. Waiting for new pod to start..."
sleep 10

echo ""
echo "4. Checking new pod status..."
kubectl get pods -n default -l app=nginx-deployment

echo ""
echo "5. Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/nginx-deployment -n default || echo "Timeout waiting for deployment"

echo ""
echo "6. Checking if Nginx is responding..."
kubectl exec -n default deployment/nginx-deployment -- nginx -t 2>&1 || echo "Nginx config test failed"

echo ""
echo "7. Testing a simple request..."
curl -I http://myfirstgitapp.local/libertyX/ 2>&1 | grep "HTTP" | head -3

echo ""
