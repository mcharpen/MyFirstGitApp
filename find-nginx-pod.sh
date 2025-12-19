#!/bin/bash

echo "======================================"
echo "Finding and Testing Nginx Pods"
echo "======================================"
echo ""

echo "1. Finding nginx pods by deployment..."
kubectl get pods -n default | grep nginx

echo ""
echo ""
echo "2. Getting pod by replicaset..."
NGINX_POD=$(kubectl get pods -n default -o name | grep nginx-deployment | head -1)
echo "Found pod: $NGINX_POD"

echo ""
echo ""
echo "3. Testing nginx config in the pod..."
kubectl exec -n default "$NGINX_POD" -- nginx -t

echo ""
echo ""
echo "4. Testing internal request..."
kubectl exec -n default "$NGINX_POD" -- curl -I http://localhost/libertyX/ 2>&1 | grep "HTTP" | head -3

echo ""
echo ""
echo "5. Testing /api/auth/providers..."
kubectl exec -n default "$NGINX_POD" -- curl -s http://localhost/api/auth/providers 2>&1 | head -10

echo ""
