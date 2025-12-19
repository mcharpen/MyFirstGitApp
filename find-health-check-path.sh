#!/bin/bash

echo "======================================"
echo "Finding a Good Readiness Probe Path"
echo "======================================"
echo ""

NGINX_POD=$(kubectl get pods -n default --sort-by=.metadata.creationTimestamp | grep nginx-deployment | tail -1 | awk '{print $1}')
echo "Testing with pod: $NGINX_POD"

echo ""
echo "Testing various paths to find one that returns 200..."
echo ""

echo "1. /libertyX/auth/ (should proxy to Keycloak)..."
kubectl exec -n default "$NGINX_POD" -- curl -I http://localhost/libertyX/auth/ 2>&1 | head -5

echo ""
echo "2. Direct nginx status (if available)..."
kubectl exec -n default "$NGINX_POD" -- curl -I http://localhost/nginx_status 2>&1 | head -5

echo ""
echo "3. Testing if we can add a simple health check location..."
echo ""

echo "The best solution is to add a dedicated /health endpoint to nginx config"
echo "that returns 200 OK without proxying anywhere."
echo ""
