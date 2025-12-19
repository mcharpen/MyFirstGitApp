#!/bin/bash
# Quick Nginx update and test

echo "=== Applying Nginx Config ==="
kubectl apply -f ansible/nginx-ingress.yml
kubectl rollout restart deployment/nginx-deployment -n default
kubectl rollout status deployment/nginx-deployment -n default
echo "✓ Nginx restarted"
echo ""

echo "=== Testing Keycloak Paths ==="
sleep 3

echo "1. Testing /libertyX/auth/realms/myapp:"
curl -s http://myfirstgitapp.local/libertyX/auth/realms/myapp/.well-known/openid-configuration | grep -q issuer && echo "✓ Works" || echo "✗ Failed"
echo ""

echo "2. Testing /libertyX/auth/admin (should redirect to login):"
curl -s -o /dev/null -w "%{http_code}" http://myfirstgitapp.local/libertyX/auth/admin
echo ""

echo "3. Testing direct Keycloak /admin:"
curl -s -o /dev/null -w "%{http_code}" http://keycloak.myfirstgitapp.svc.cluster.local:8080/admin
echo ""

echo ""
echo "If tests fail, check nginx logs:"
echo "  kubectl logs -n default -l app=nginx --tail=30"
