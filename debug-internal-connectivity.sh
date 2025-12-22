#!/bin/bash
echo "=== Debugging Internal Connectivity ==="
FRONTEND_POD=$(kubectl get pods -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].metadata.name}')
echo "Frontend Pod: $FRONTEND_POD"

echo ""
echo "1. Checking /etc/hosts in frontend..."
kubectl exec -n myfirstgitapp $FRONTEND_POD -- cat /etc/hosts

echo ""
echo "2. Testing curl to KEYCLOAK_ISSUER (HTTPS)..."
# Expecting failure if pointing to internal HTTP port
kubectl exec -n myfirstgitapp $FRONTEND_POD -- wget -qO- --server-response --timeout=5 https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration 2>&1 | head -n 10

echo ""
echo "3. Testing curl to Internal Keycloak (HTTP)..."
kubectl exec -n myfirstgitapp $FRONTEND_POD -- wget -qO- --server-response --timeout=5 http://keycloak:8080/libertyX/auth/realms/myapp/.well-known/openid-configuration 2>&1 | head -n 10
