#!/bin/bash

echo "=== Rebuilding and deploying frontend with fixed Nginx headers ==="

cd /Users/mcharpen/GIT/MyFirstGitApp/frontend

echo ""
echo "1. Building Docker image..."
docker build -t mcharpen5/myfirstgitapp-frontend:latest .

echo ""
echo "2. Pushing to Docker Hub..."
docker push mcharpen5/myfirstgitapp-frontend:latest

echo ""
echo "3. Restarting frontend deployment..."
kubectl rollout restart deployment/frontend -n myfirstgitapp

echo ""
echo "4. Waiting for rollout to complete..."
kubectl rollout status deployment/frontend -n myfirstgitapp

echo ""
echo "5. Testing the providers endpoint..."
sleep 5
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers | jq .

echo ""
echo "6. Checking frontend logs for header values..."
FRONTEND_POD=$(kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].metadata.name}')
echo "Frontend pod: $FRONTEND_POD"
echo ""
echo "Triggering a request and checking logs..."
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers > /dev/null
sleep 2
kubectl logs -n myfirstgitapp $FRONTEND_POD --tail=30 | grep -A 5 "Request headers"

echo ""
echo "✅ Done! Check if the URLs now use the correct host."
