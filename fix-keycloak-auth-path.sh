#!/bin/bash
# Simple fix for Keycloak /auth path

set -e

echo "=== Fixing Keycloak Configuration ==="
echo ""

echo "Step 1: Applying updated Keycloak config (without KC_HTTP_RELATIVE_PATH)"
kubectl apply -f k8s/keycloak.yaml
echo ""

echo "Step 2: Deleting Keycloak pod to force restart with new config"
kubectl delete pod -n myfirstgitapp -l app=keycloak
echo ""

echo "Step 3: Waiting for Keycloak to be ready..."
kubectl wait --for=condition=ready pod -l app=keycloak -n myfirstgitapp --timeout=120s
sleep 20
echo "✓ Keycloak is ready"
echo ""

echo "Step 4: Testing Keycloak direct connection (without /auth)"
kubectl run test-kc --image=curlimages/curl --rm -i --restart=Never -- \
  curl -s http://keycloak.myfirstgitapp.svc.cluster.local:8080/realms/myapp/.well-known/openid-configuration \
  | grep -q issuer && echo "✓ Keycloak root path works" || echo "✗ Keycloak root path failed"
echo ""

echo "Step 5: Applying Nginx config with URL rewriting (/auth → /)"
kubectl apply -f ansible/nginx-ingress.yml
kubectl rollout restart deployment/nginx-deployment -n default
kubectl rollout status deployment/nginx-deployment -n default
echo "✓ Nginx updated"
echo ""

echo "Step 6: Testing via Ingress with /auth path"
sleep 5
curl -s http://myfirstgitapp.local/auth/realms/myapp/.well-known/openid-configuration \
  | grep -q issuer && echo "✓ Keycloak accessible via /auth" || echo "✗ /auth path not working"
echo ""

echo "Step 7: Updating frontend to use https://olite.hd.free.fr/auth/realms/myapp"
kubectl apply -f k8s/frontend.yaml
kubectl rollout restart deployment/frontend -n myfirstgitapp
kubectl rollout status deployment/frontend -n myfirstgitapp
echo "✓ Frontend updated"
echo ""

echo "=== Configuration Complete ==="
echo ""
echo "Keycloak URLs:"
echo "  - Admin Console (NodePort): http://dev2.sophia.com:32089/admin"
echo "  - Admin Console (Ingress): http://myfirstgitapp.local/auth/admin"
echo "  - Public (after external nginx): https://olite.hd.free.fr/auth/admin"
echo ""
echo "Test the app:"
echo "  - Local: http://myfirstgitapp.local/libertyX/"
echo "  - Public: https://olite.hd.free.fr/libertyX/"
echo ""
