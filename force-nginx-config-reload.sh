#!/bin/bash

echo "======================================"
echo "Checking Current Nginx Configuration"
echo "======================================"
echo ""

NGINX_POD=$(kubectl get pods -n default -o name | grep nginx-deployment | grep Running | head -1)
echo "Using pod: $NGINX_POD"

echo ""
echo "1. Checking /api/ location configuration..."
kubectl exec -n default "$NGINX_POD" -- nginx -T 2>&1 | grep -A 8 "location /api/"

echo ""
echo ""
echo "2. Checking nginx-conf ConfigMap..."
kubectl get configmap nginx-conf -n default -o yaml | grep -A 3 "location /api/"

echo ""
echo ""
echo "3. Force deleting the old pod to pick up new config..."
kubectl delete pod -n default nginx-deployment-6cf475d8b8-gxqqh --force --grace-period=0

echo ""
echo "4. Waiting for new pod..."
sleep 10

echo ""
echo "5. Checking new pod status..."
kubectl get pods -n default | grep nginx

echo ""
echo "6. Testing /api/auth/providers from new pod..."
sleep 5
NEW_POD=$(kubectl get pods -n default -o name | grep nginx-deployment | grep Running | head -1)
echo "Testing with: $NEW_POD"
kubectl exec -n default "$NEW_POD" -- curl -s http://localhost/api/auth/providers 2>&1 | head -20

echo ""
