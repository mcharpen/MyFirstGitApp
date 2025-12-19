#!/bin/bash
# Test if Nginx can reach Keycloak and if location blocks work

echo "=== Testing from inside Nginx pod ==="
NGINX_POD=$(kubectl get pod -n default -l app=nginx -o jsonpath='{.items[0].metadata.name}')

echo "1. Testing Nginx → Keycloak direct connection:"
kubectl exec -n default $NGINX_POD -- wget -qO- http://keycloak.myfirstgitapp.svc.cluster.local:8080/admin 2>&1 | head -5
echo ""

echo "2. Testing Nginx location matching:"
echo "Sending request to http://myfirstgitapp.local/libertyX/auth/realms/myapp/.well-known/openid-configuration"
curl -v http://myfirstgitapp.local/libertyX/auth/realms/myapp/.well-known/openid-configuration 2>&1 | head -40
echo ""

echo "3. Checking nginx access logs for /libertyX/auth requests:"
kubectl logs -n default $NGINX_POD --tail=10 | grep -i "libertyX/auth" || echo "No requests to /libertyX/auth found"
echo ""

echo "4. Testing with explicit Host header:"
curl -v -H "Host: myfirstgitapp.local" http://10.17.1.200/libertyX/auth/realms/myapp/.well-known/openid-configuration 2>&1 | head -30
