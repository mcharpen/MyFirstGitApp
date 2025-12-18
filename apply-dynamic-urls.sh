#!/bin/bash
set -e

echo "Step 1: Building frontend image with dynamic URL configuration..."
cd /Users/mcharpen/GIT/MyFirstGitApp/frontend
docker build -t mcharpen5/myfirstapp-frontend:latest .

echo "Step 2: Pushing to Docker Hub..."
docker push mcharpen5/myfirstapp-frontend:latest

echo "Step 3: Applying updated frontend deployment..."
kubectl apply -f /Users/mcharpen/GIT/MyFirstGitApp/k8s/frontend.yaml

echo "Step 4: Restarting frontend deployment..."
kubectl rollout restart deployment/frontend -n myfirstgitapp

echo "Step 5: Waiting for frontend to be ready..."
kubectl rollout status deployment/frontend -n myfirstgitapp

echo "Step 6: Updating Keycloak redirect URIs..."
bash /Users/mcharpen/GIT/MyFirstGitApp/update-keycloak-dual-urls.sh

echo ""
echo "✅ All done! Testing endpoints..."
echo ""

sleep 5

echo "Testing local URL (if /etc/hosts is configured):"
curl -s http://myfirstgitapp.local/libertyX/api/auth/providers 2>/dev/null | jq . || echo "Local URL not accessible (this is OK if not testing locally)"

echo ""
echo "Testing public URL:"
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers | jq .

echo ""
echo "✅ Setup complete! Both URLs should now work with Keycloak authentication."
