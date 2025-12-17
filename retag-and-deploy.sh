#!/bin/bash

echo "======================================"
echo "Retag, Push and Deploy with Correct Username"
echo "======================================"
echo ""

echo "1. Retagging image with correct username (mcharpen5)..."
docker tag mcharpen/myfirstgitapp-frontend:trailingslash-fix mcharpen5/myfirstgitapp-frontend:trailingslash-fix

if [ $? -ne 0 ]; then
  echo "❌ Docker tag failed"
  exit 1
fi

echo "✓ Retagged successfully"
echo ""

echo "2. Pushing to Docker Hub (mcharpen5)..."
docker push mcharpen5/myfirstgitapp-frontend:trailingslash-fix

if [ $? -ne 0 ]; then
  echo "❌ Docker push failed"
  exit 1
fi

echo "✓ Push successful"
echo ""

echo "3. Updating Kubernetes deployment..."
kubectl set image deployment/frontend -n myfirstgitapp frontend=mcharpen5/myfirstgitapp-frontend:trailingslash-fix

echo ""
echo "4. Waiting for rollout..."
kubectl rollout status deployment/frontend -n myfirstgitapp

echo ""
echo "5. Waiting 10 seconds for pod to be ready..."
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
