#!/bin/bash
# Debug Keycloak connectivity

echo "=== Checking Keycloak Pod ==="
kubectl get pods -n myfirstgitapp -l app=keycloak
echo ""

echo "=== Checking Keycloak Service ==="
kubectl get svc -n myfirstgitapp keycloak
echo ""

echo "=== Testing Keycloak Direct (from a test pod) ==="
kubectl run test-kc-debug --image=curlimages/curl --rm -i --restart=Never -- \
  sh -c "curl -v http://keycloak.myfirstgitapp.svc.cluster.local:8080/admin 2>&1 | head -30"
echo ""

echo "=== Checking Keycloak Logs ==="
kubectl logs -n myfirstgitapp -l app=keycloak --tail=50
echo ""

echo "=== Testing Nginx Config ==="
kubectl exec -n default deployment/nginx-deployment -- nginx -T 2>&1 | grep -A 20 "location.*libertyX/auth"
