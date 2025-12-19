#!/bin/bash

set -e

echo "======================================"
echo "Fixing OAuth Issuer Configuration"
echo "======================================"
echo ""

echo "Issue: Frontend needs to use internal cluster URL to reach Keycloak"
echo "Fix: Set KEYCLOAK_ISSUER to http://keycloak.myfirstgitapp.svc.cluster.local:8080/libertyX/auth/realms/myapp"
echo ""

echo "1. Applying updated frontend configuration..."
kubectl apply -f k8s/frontend.yaml

echo ""
echo "2. Waiting for frontend rollout..."
kubectl rollout status deployment/frontend -n myfirstgitapp --timeout=120s

echo ""
echo "3. Waiting 5 seconds for pod to initialize..."
sleep 5

echo ""
echo "4. Testing if frontend can reach Keycloak..."
echo ""
kubectl exec -n myfirstgitapp deployment/frontend -- sh -c "wget -q -O- http://keycloak.myfirstgitapp.svc.cluster.local:8080/libertyX/auth/realms/myapp/.well-known/openid-configuration" | jq -r '.issuer' || echo "Failed"

echo ""
echo ""
echo "5. Checking frontend logs for any startup errors..."
kubectl logs -n myfirstgitapp deployment/frontend --tail=20

echo ""
echo ""
echo "======================================"
echo "Configuration Updated!"
echo "======================================"
echo ""
echo "However, there's still an issuer mismatch issue:"
echo "  - Keycloak returns: https://olite.hd.free.fr/libertyX/auth/realms/myapp"
echo "  - Frontend expects: http://keycloak.myfirstgitapp.svc.cluster.local:8080/libertyX/auth/realms/myapp"
echo ""
echo "NextAuth will reject the token because the issuer doesn't match!"
echo ""
echo "We need to either:"
echo "  A) Make Keycloak return the internal URL as issuer (breaks browser access)"
echo "  B) Make frontend use the external URL and route it through Nginx"
echo "  C) Disable issuer validation in NextAuth (not recommended)"
echo ""
