#!/bin/bash
echo "=== Debugging 404 on /libertyX/ ==="

echo "1. Getting Nginx Pod..."
NGINX_POD=$(kubectl get pods -n myfirstgitapp -l app=nginx -o jsonpath='{.items[0].metadata.name}')
echo "Nginx Pod: $NGINX_POD"

echo ""
echo "2. Checking Nginx generated config..."
kubectl exec -n myfirstgitapp $NGINX_POD -- cat /etc/nginx/nginx.conf | grep -A 20 "location /libertyX/"

echo ""
echo "3. Testing connection from Nginx -> Frontend..."
kubectl exec -n myfirstgitapp $NGINX_POD -- wget -qO- --server-response http://frontend.myfirstgitapp.svc.cluster.local:3000/libertyX/ 2>&1 | head -n 20

echo ""
echo "4. Testing connection from Nginx -> Frontend (without trailing slash)..."
kubectl exec -n myfirstgitapp $NGINX_POD -- wget -qO- --server-response http://frontend.myfirstgitapp.svc.cluster.local:3000/libertyX 2>&1 | head -n 20

echo ""
echo "5. Checking Frontend Logs..."
kubectl logs -n myfirstgitapp -l app=frontend --tail=20
