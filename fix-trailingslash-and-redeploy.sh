#!/bin/bash

echo "======================================"
echo "Fixing Trailing Slash Issue"
echo "======================================"
echo ""

echo "1. Building new frontend image with trailingSlash: true..."
cd frontend
docker build -t mcharpen/myfirstgitapp-frontend:trailingslash-fix .

if [ $? -ne 0 ]; then
  echo "❌ Docker build failed"
  exit 1
fi
echo "✓ Build successful"
echo ""

echo "2. Pushing to Docker Hub..."
docker push mcharpen/myfirstgitapp-frontend:trailingslash-fix

if [ $? -ne 0 ]; then
  echo "❌ Docker push failed"
  exit 1
fi
echo "✓ Push successful"
echo ""

cd ..

echo "3. Updating frontend deployment..."
kubectl set image deployment/frontend -n myfirstgitapp frontend=mcharpen/myfirstgitapp-frontend:trailingslash-fix

echo ""
echo "4. Waiting for rollout..."
kubectl rollout status deployment/frontend -n myfirstgitapp

echo ""
echo "5. Waiting 10 seconds for the new pod to be ready..."
sleep 10

echo ""
echo "6. Testing the fix..."
echo "Testing https://olite.hd.free.fr/libertyX/ (max 5 redirects):"
curl -sI -L --max-redirs 5 https://olite.hd.free.fr/libertyX/ 2>&1 | grep -E "HTTP|Location:"

echo ""
echo "======================================"
echo "Testing content retrieval:"
curl -s --max-redirs 10 https://olite.hd.free.fr/libertyX/ 2>&1 | head -30
echo ""
echo "======================================"
echo "✓ Fix applied!"
echo "Now test in browser: https://olite.hd.free.fr/libertyX/"
echo "======================================"
