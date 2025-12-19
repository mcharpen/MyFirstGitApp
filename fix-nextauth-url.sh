#!/bin/bash

echo "======================================"
echo "Fixing NEXTAUTH_URL and Rebuilding"
echo "======================================"
echo ""

echo "1. Building new frontend image with fixed NextAuth config..."
cd frontend
docker build -t mcharpen5/myfirstgitapp-frontend:nextauth-fix .

if [ $? -ne 0 ]; then
  echo "❌ Docker build failed"
  exit 1
fi
echo "✓ Build successful"
cd ..
echo ""

echo "2. Pushing to Docker Hub..."
docker push mcharpen5/myfirstgitapp-frontend:nextauth-fix

if [ $? -ne 0 ]; then
  echo "❌ Docker push failed"
  exit 1
fi
echo "✓ Push successful"
echo ""

echo "3. Applying updated frontend deployment (with NEXTAUTH_URL fix)..."
kubectl apply -f k8s/frontend.yaml

echo ""
echo "4. Updating frontend image..."
kubectl set image deployment/frontend -n myfirstgitapp frontend=mcharpen5/myfirstgitapp-frontend:nextauth-fix

echo ""
echo "5. Waiting for rollout..."
kubectl rollout status deployment/frontend -n myfirstgitapp

echo ""
echo "6. Waiting 10 seconds for pod to be ready..."
sleep 10

echo ""
echo "======================================"
echo "Testing the fix..."
echo "======================================"
echo ""

echo "Test 1: Check environment variables:"
FRONTEND_POD=$(kubectl get pods -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n myfirstgitapp $FRONTEND_POD -- env | grep -E "NEXTAUTH_URL|KEYCLOAK_ISSUER"

echo ""
echo "Test 2: Test /api/auth/providers (should return JSON):"
curl -s https://olite.hd.free.fr/api/auth/providers | head -20

echo ""
echo "Test 3: Test main page:"
curl -sI https://olite.hd.free.fr/libertyX/ | grep HTTP

echo ""
echo "======================================"
echo "✓ Fix applied!"
echo ""
echo "Now test the Keycloak login button at:"
echo "https://olite.hd.free.fr/libertyX/"
echo "======================================"
