#!/bin/bash

set -e

echo "======================================"
echo "Rebuilding Frontend with OAuth Fix"
echo "======================================"
echo ""

cd frontend

echo "1. Building new frontend image..."
docker build -t docker.io/mcharpen5/myfirstapp-frontend:latest .

echo ""
echo "2. Pushing to Docker Hub..."
docker push docker.io/mcharpen5/myfirstapp-frontend:latest

echo ""
echo "3. Restarting frontend deployment to pull new image..."
cd ..
kubectl rollout restart deployment/frontend -n myfirstgitapp
kubectl rollout status deployment/frontend -n myfirstgitapp --timeout=180s

echo ""
echo "4. Waiting for frontend to stabilize..."
sleep 10

echo ""
echo "5. Testing NextAuth providers endpoint..."
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers | jq '.'

echo ""
echo ""
echo "======================================"
echo "Frontend Rebuilt and Deployed!"
echo "======================================"
echo ""
echo "Try the login flow again at:"
echo "  https://olite.hd.free.fr/libertyX/"
echo ""
echo "Changes made:"
echo "  - Added PKCE and state checks to NextAuth"
echo "  - Frontend now uses external Keycloak URL (https://olite.hd.free.fr/libertyX/auth/realms/myapp)"
echo "  - This matches the issuer that Keycloak returns"
echo ""
