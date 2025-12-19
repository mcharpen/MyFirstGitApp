#!/bin/bash

echo "======================================"
echo "Debugging OAuth Sign-in Error"
echo "======================================"
echo ""

echo "1. Checking frontend logs for OAuth errors..."
echo ""
kubectl logs -n myfirstgitapp deployment/frontend --tail=50 | grep -i -A 5 -B 5 "error\|oauth\|keycloak\|callback" || echo "No error logs found"

echo ""
echo ""
echo "2. Checking Keycloak logs for authentication attempts..."
echo ""
kubectl logs -n myfirstgitapp deployment/keycloak --tail=50 | grep -i -A 3 "error\|callback\|token\|authentication" || echo "No relevant logs"

echo ""
echo ""
echo "3. Testing Keycloak token endpoint directly..."
echo ""
curl -I https://olite.hd.free.fr/libertyX/auth/realms/myapp/protocol/openid-connect/token 2>&1 | grep -E "(HTTP|Content-Type)" | head -5

echo ""
echo ""
echo "4. Checking if Keycloak issuer matches frontend config..."
echo ""
echo "Keycloak issuer:"
curl -s https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq -r '.issuer'

echo ""
echo "Frontend KEYCLOAK_ISSUER env var:"
kubectl get deployment frontend -n myfirstgitapp -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="KEYCLOAK_ISSUER")].value}'
echo ""

echo ""
echo ""
echo "5. Testing if frontend can reach Keycloak from inside the pod..."
echo ""
kubectl exec -n myfirstgitapp deployment/frontend -- wget -q -O- http://keycloak.myfirstgitapp.svc.cluster.local:8080/libertyX/auth/realms/myapp/.well-known/openid-configuration 2>&1 | head -10 || echo "Failed to reach Keycloak from frontend pod"

echo ""
echo ""
echo "6. Checking NextAuth environment variables..."
echo ""
kubectl get deployment frontend -n myfirstgitapp -o jsonpath='{.spec.template.spec.containers[0].env[*].name}' | tr ' ' '\n' | grep -E "KEYCLOAK|NEXTAUTH"
echo ""

echo ""
echo "======================================"
echo "Debug Complete"
echo "======================================"
