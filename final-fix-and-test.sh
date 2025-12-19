#!/bin/bash

echo "======================================"
echo "Final Fix: Rebuild Without trailingSlash"
echo "======================================"
echo ""

echo "Changes made:"
echo "- Removed trailingSlash: true from next.config.js"
echo "- NEXTAUTH_URL already fixed to https://olite.hd.free.fr"
echo "- NextAuth error page already fixed to /api/auth/error"
echo ""

echo "1. Building new frontend image..."
cd frontend
docker build -t mcharpen5/myfirstgitapp-frontend:final-fix .

if [ $? -ne 0 ]; then
  echo "❌ Docker build failed"
  echo "Try again in a few minutes if Docker Hub is having issues"
  exit 1
fi
echo "✓ Build successful"
cd ..
echo ""

echo "2. Pushing to Docker Hub..."
docker push mcharpen5/myfirstgitapp-frontend:final-fix

if [ $? -ne 0 ]; then
  echo "❌ Docker push failed"
  exit 1
fi
echo "✓ Push successful"
echo ""

echo "3. Updating deployment..."
kubectl set image deployment/frontend -n myfirstgitapp frontend=mcharpen5/myfirstgitapp-frontend:final-fix

echo ""
echo "4. Waiting for rollout..."
kubectl rollout status deployment/frontend -n myfirstgitapp

echo ""
echo "5. Waiting 10 seconds..."
sleep 10

echo ""
echo "======================================"
echo "Testing All Endpoints"
echo "======================================"
echo ""

echo "Test 1: Main page (should return 200):"
curl -sI https://olite.hd.free.fr/libertyX/ | grep HTTP

echo ""
echo "Test 2: API providers endpoint (should return JSON, not 404):"
curl -s https://olite.hd.free.fr/api/auth/providers

echo ""
echo "Test 3: Check for redirect loops (should not loop):"
curl -sI -L --max-redirs 5 https://olite.hd.free.fr/libertyX/ | grep -E "HTTP|Location:"

echo ""
echo "======================================"
echo "✓ All fixes applied!"
echo ""
echo "Now test the full login flow:"
echo "1. Go to https://olite.hd.free.fr/libertyX/"
echo "2. Click the Keycloak button"
echo "3. Login should work without 404 errors"
echo "======================================"
