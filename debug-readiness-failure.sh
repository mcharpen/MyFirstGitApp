#!/bin/bash

echo "======================================"
echo "Debugging Readiness Probe Failure"
echo "======================================"
echo ""

echo "1. Getting newest nginx pod..."
NEWEST_POD=$(kubectl get pods -n default --sort-by=.metadata.creationTimestamp | grep nginx-deployment | tail -1 | awk '{print $1}')
echo "Pod: $NEWEST_POD"

echo ""
echo "2. Checking pod events..."
kubectl describe pod "$NEWEST_POD" -n default | grep -A 20 "Events:"

echo ""
echo "3. Testing readiness probe path manually..."
kubectl exec -n default "$NEWEST_POD" -- curl -I http://localhost/libertyX/ 2>&1 | head -10

echo ""
echo "4. Checking if there's a redirect loop..."
kubectl exec -n default "$NEWEST_POD" -- curl -v http://localhost/libertyX/ 2>&1 | grep -E "(HTTP|Location)" | head -20

echo ""
echo "5. Checking nginx error logs..."
kubectl logs -n default "$NEWEST_POD" --tail=30 | tail -15

echo ""
echo "6. Testing if nginx is actually running..."
kubectl exec -n default "$NEWEST_POD" -- ps aux | grep nginx

echo ""
