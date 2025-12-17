#!/bin/bash

echo "======================================"
echo "Moving Ingress to Default Namespace"
echo "======================================"
echo ""

echo "1. Deleting old Ingress and nginx-proxy service from myfirstgitapp namespace..."
kubectl delete ingress myfirstgitapp -n myfirstgitapp
kubectl delete svc nginx-proxy -n myfirstgitapp 2>/dev/null || echo "nginx-proxy service not found (ok)"

echo ""
echo "2. Applying new Ingress in default namespace..."
kubectl apply -f k8s/ingress.yaml

echo ""
echo "3. Checking certificate status..."
echo "NOTE: The certificate will need to be re-issued in the default namespace."
echo "This may take a few minutes."
kubectl get certificate -n default

echo ""
echo "4. Waiting 10 seconds..."
sleep 10

echo ""
echo "======================================"
echo "Testing All Endpoints"
echo "======================================"
echo ""

echo "Test 1: Main page:"
curl -sI https://olite.hd.free.fr/libertyX/ | grep HTTP

echo ""
echo "Test 2: API providers (should work now!):"
curl -s https://olite.hd.free.fr/api/auth/providers

echo ""
echo "Test 3: Backend /emp endpoint:"
curl -s https://olite.hd.free.fr/emp | head -5

echo ""
echo "======================================"
echo "If Test 2 now returns JSON, the fix is complete!"
echo ""
echo "The certificate may take a few minutes to be issued."
echo "Check status with: kubectl get certificate -n default"
echo "======================================"
