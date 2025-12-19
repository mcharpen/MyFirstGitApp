#!/bin/bash

echo "======================================"
echo "Fixing Redirect Loop"
echo "======================================"
echo ""

echo "1. Applying updated Ingress..."
kubectl apply -f k8s/ingress.yaml

echo ""
echo "2. Applying updated Nginx ConfigMap..."
kubectl apply -f k8s/nginx-configmap-fixed.yaml

echo ""
echo "3. Restarting Nginx pod to apply config..."
kubectl rollout restart deployment nginx-deployment -n default

echo ""
echo "4. Waiting for rollout..."
kubectl rollout status deployment nginx-deployment -n default

echo ""
echo "5. Testing after fix (waiting 5 seconds first)..."
sleep 5

echo ""
echo "Testing https://olite.hd.free.fr/libertyX/ (max 5 redirects):"
curl -sI -L --max-redirs 5 https://olite.hd.free.fr/libertyX/ 2>&1 | grep -E "HTTP|Location:"

echo ""
echo "======================================"
echo "If successful, you should see HTTP 200 OK"
echo "======================================"
