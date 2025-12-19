#!/bin/bash

echo "======================================"
echo "Docker Login and Push"
echo "======================================"
echo ""

echo "Please login to Docker Hub:"
docker login

if [ $? -ne 0 ]; then
  echo "❌ Docker login failed"
  exit 1
fi

echo ""
echo "Pushing frontend image..."
docker push mcharpen/myfirstgitapp-frontend:trailingslash-fix

if [ $? -ne 0 ]; then
  echo "❌ Docker push failed"
  exit 1
fi

echo "✓ Push successful"
echo ""

echo "Updating Kubernetes deployment..."
kubectl set image deployment/frontend -n myfirstgitapp frontend=mcharpen/myfirstgitapp-frontend:trailingslash-fix

echo ""
echo "Waiting for rollout..."
kubectl rollout status deployment/frontend -n myfirstgitapp

echo ""
echo "Waiting 10 seconds for pod to be ready..."
sleep 10

echo ""
echo "======================================"
echo "Testing the fix..."
echo "======================================"
echo ""
echo "Test 1: Check redirect chain (should not loop):"
curl -sI -L --max-redirs 5 https://olite.hd.free.fr/libertyX/ 2>&1 | grep -E "HTTP|Location:"

echo ""
echo "Test 2: Fetch content (should get HTML):"
curl -s --max-redirs 10 https://olite.hd.free.fr/libertyX/ 2>&1 | head -20

echo ""
echo "======================================"
echo "✓ Deployment complete!"
echo "Now test in browser: https://olite.hd.free.fr/libertyX/"
echo "======================================"
