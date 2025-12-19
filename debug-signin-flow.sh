#!/bin/bash

echo "=== Debugging NextAuth Sign-in Flow ==="
echo ""

echo "1. Testing NextAuth providers endpoint:"
curl -v https://olite.hd.free.fr/libertyX/api/auth/providers 2>&1 | grep -E "< HTTP|< Location|keycloak"
echo ""

echo "2. Testing NextAuth signin endpoint with verbose output:"
RESPONSE=$(curl -s -L -v https://olite.hd.free.fr/libertyX/api/auth/signin/keycloak 2>&1)

echo "Response contains Keycloak URL:"
echo "$RESPONSE" | grep -o "https://olite.hd.free.fr/libertyX/auth/realms/myapp[^\"]*" | head -1
echo ""

echo "3. Check frontend pod logs for any errors:"
FRONTEND_POD=$(kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].metadata.name}')
echo "Frontend pod: $FRONTEND_POD"
echo ""
echo "Recent frontend logs:"
kubectl logs -n myfirstgitapp $FRONTEND_POD --tail=20

echo ""
echo "4. Check Nginx logs:"
NGINX_POD=$(kubectl get pod -n default -l app=nginx -o jsonpath='{.items[0].metadata.name}')
echo "Nginx pod: $NGINX_POD"
echo ""
echo "Recent Nginx access logs:"
kubectl logs -n default $NGINX_POD --tail=20 | grep -E "libertyX/api/auth"
