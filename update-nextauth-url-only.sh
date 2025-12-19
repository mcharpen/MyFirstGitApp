#!/bin/bash

echo "======================================"
echo "Updating NEXTAUTH_URL (No Rebuild)"
echo "======================================"
echo ""

echo "Since we only changed environment variables in the deployment,"
echo "we can apply the changes without rebuilding the image."
echo ""

echo "1. Applying updated frontend deployment (NEXTAUTH_URL without /libertyX)..."
kubectl apply -f k8s/frontend.yaml

echo ""
echo "2. Restarting frontend pods to pick up new env vars..."
kubectl rollout restart deployment/frontend -n myfirstgitapp

echo ""
echo "3. Waiting for rollout..."
kubectl rollout status deployment/frontend -n myfirstgitapp

echo ""
echo "4. Waiting 10 seconds for pod to be ready..."
sleep 10

echo ""
echo "======================================"
echo "Testing the configuration..."
echo "======================================"
echo ""

echo "Test 1: Check new environment variable:"
FRONTEND_POD=$(kubectl get pods -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].metadata.name}')
echo "Frontend Pod: $FRONTEND_POD"
echo ""
echo "NEXTAUTH_URL should be: https://olite.hd.free.fr (without /libertyX)"
kubectl exec -n myfirstgitapp $FRONTEND_POD -- env | grep NEXTAUTH_URL

echo ""
echo "Test 2: Test /api/auth/providers endpoint:"
echo "Internal:"
kubectl run -n myfirstgitapp test-api-providers --image=curlimages/curl:latest --rm -i --restart=Never -- curl -s http://frontend.myfirstgitapp.svc.cluster.local:3000/api/auth/providers 2>&1 | head -10

echo ""
echo "External (through Nginx):"
curl -s https://olite.hd.free.fr/api/auth/providers 2>&1 | head -10

echo ""
echo "======================================"
echo "Note: The NextAuth error page fix requires rebuilding."
echo "We'll need to rebuild once Docker Hub is back up."
echo "For now, test if the Keycloak button works at:"
echo "https://olite.hd.free.fr/libertyX/"
echo "======================================"
