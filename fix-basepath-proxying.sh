#!/bin/bash

echo "======================================"
echo "Fixing BasePath Proxying"
echo "======================================"
echo ""

echo "1. Applying updated Nginx ConfigMap (strip /libertyX before proxying to Next.js)..."
kubectl apply -f k8s/nginx-configmap-fixed.yaml

echo ""
echo "2. Restarting Nginx pod..."
kubectl rollout restart deployment nginx-deployment -n default

echo ""
echo "3. Waiting for rollout..."
kubectl rollout status deployment nginx-deployment -n default

echo ""
echo "4. Waiting 5 seconds..."
sleep 5

echo ""
echo "======================================"
echo "Testing the fix..."
echo "======================================"
echo ""

echo "Test 1: Direct frontend test (should return 200):"
kubectl run -n myfirstgitapp test-curl --image=curlimages/curl:latest --rm -i --restart=Never -- curl -sI http://frontend.myfirstgitapp.svc.cluster.local:3000/ | head -5

echo ""
echo "Test 2: Through Nginx internally (should return 200):"
kubectl run -n default test-curl2 --image=curlimages/curl:latest --rm -i --restart=Never -- curl -sI http://nginx.default.svc.cluster.local/libertyX/ | head -5

echo ""
echo "Test 3: External HTTPS access (should return 200):"
curl -sI -L --max-redirs 5 https://olite.hd.free.fr/libertyX/ | grep -E "HTTP|Location:"

echo ""
echo "Test 4: Fetch HTML content:"
curl -s --max-redirs 10 https://olite.hd.free.fr/libertyX/ | head -30

echo ""
echo "======================================"
echo "✓ Fix applied!"
echo "Now test in browser: https://olite.hd.free.fr/libertyX/"
echo "======================================"
