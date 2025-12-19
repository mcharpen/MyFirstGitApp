#!/bin/bash
# Debug Keycloak /auth path issue

echo "=== Checking Keycloak Status ==="
echo ""

echo "Keycloak pod status:"
kubectl get pods -n myfirstgitapp -l app=keycloak
echo ""

echo "=== Keycloak Logs (last 30 lines) ==="
kubectl logs -n myfirstgitapp -l app=keycloak --tail=30
echo ""

echo "=== Testing Keycloak Direct Connection ==="
echo "Testing without /auth path:"
kubectl run -it --rm test-kc-direct --image=curlimages/curl --restart=Never -- \
  curl -v http://keycloak.myfirstgitapp.svc.cluster.local:8080/realms/myapp/.well-known/openid-configuration 2>&1 | head -20
echo ""

echo "Testing with /auth path:"
kubectl run -it --rm test-kc-auth --image=curlimages/curl --restart=Never -- \
  curl -v http://keycloak.myfirstgitapp.svc.cluster.local:8080/auth/realms/myapp/.well-known/openid-configuration 2>&1 | head -20
echo ""

echo "=== Internal Nginx Logs ==="
kubectl logs -n default -l app=nginx --tail=20
echo ""

echo "=== Testing via Ingress ==="
curl -v http://myfirstgitapp.local/auth/realms/myapp/.well-known/openid-configuration 2>&1 | head -30
