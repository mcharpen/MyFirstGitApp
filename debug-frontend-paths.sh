#!/bin/bash
echo "=== Debugging Frontend Paths ==="

echo "1. Getting Nginx Pod..."
NGINX_POD=$(kubectl get pods -n myfirstgitapp -l app=nginx -o jsonpath='{.items[0].metadata.name}')
echo "Nginx Pod: $NGINX_POD"

echo ""
echo "2. Testing common paths directly from Nginx -> Frontend..."

echo "-- Requesting /libertyX/ --"
kubectl exec -n myfirstgitapp $NGINX_POD -- wget -qO- --server-response http://frontend.myfirstgitapp.svc.cluster.local:3000/libertyX/ 2>&1 | head -n 5

echo ""
echo "-- Requesting / (root) --"
kubectl exec -n myfirstgitapp $NGINX_POD -- wget -qO- --server-response http://frontend.myfirstgitapp.svc.cluster.local:3000/ 2>&1 | head -n 5

echo ""
echo "-- Requesting /api/health --"
kubectl exec -n myfirstgitapp $NGINX_POD -- wget -qO- --server-response http://frontend.myfirstgitapp.svc.cluster.local:3000/api/health 2>&1 | head -n 5

echo ""
echo "-- Requesting /libertyX/api/health --"
kubectl exec -n myfirstgitapp $NGINX_POD -- wget -qO- --server-response http://frontend.myfirstgitapp.svc.cluster.local:3000/libertyX/api/health 2>&1 | head -n 5
