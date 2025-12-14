#!/bin/bash
# Deploy Keycloak with public HTTPS access via Ingress

set -e

echo "=== Deploying Keycloak with Public HTTPS Access ==="
echo ""

echo "Step 1: Updating internal Nginx to proxy Keycloak at /auth"
kubectl apply -f ansible/nginx-ingress.yml
kubectl rollout restart deployment/nginx-deployment -n default
echo "✓ Internal Nginx updated"
echo ""

echo "Step 2: Updating Keycloak deployment with /auth base path"
kubectl apply -f k8s/keycloak.yaml
kubectl rollout restart deployment/keycloak -n myfirstgitapp
echo "✓ Keycloak configuration updated"
echo ""

echo "Step 3: Waiting for Keycloak to be ready..."
kubectl rollout status deployment/keycloak -n myfirstgitapp
sleep 10
echo "✓ Keycloak is ready"
echo ""

echo "Step 4: Updating frontend with public Keycloak URL"
kubectl apply -f k8s/frontend.yaml
kubectl rollout restart deployment/frontend -n myfirstgitapp
echo "✓ Frontend configuration updated"
echo ""

echo "Step 5: Waiting for frontend to be ready..."
kubectl rollout status deployment/frontend -n myfirstgitapp
echo "✓ Frontend is ready"
echo ""

echo "=== Verifying Configuration ==="
echo ""
echo "Frontend KEYCLOAK_ISSUER:"
kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].spec.containers[0].env[?(@.name=="KEYCLOAK_ISSUER")].value}'
echo ""
echo ""
echo "Frontend NEXTAUTH_URL:"
kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].spec.containers[0].env[?(@.name=="NEXTAUTH_URL")].value}'
echo ""
echo ""

echo "=== Testing Keycloak via Ingress ==="
echo "Testing: http://myfirstgitapp.local/auth/realms/myapp/.well-known/openid-configuration"
curl -s http://myfirstgitapp.local/auth/realms/myapp/.well-known/openid-configuration | grep -q issuer && echo "✓ Keycloak is accessible via Ingress" || echo "✗ Keycloak is NOT accessible"
echo ""

echo "=== Next Steps ==="
echo ""
echo "1. Update external Nginx on olite.hd.free.fr with the config from external-nginx-config.conf"
echo ""
echo "2. Update Keycloak client in Admin Console:"
echo "   - Go to: http://dev2.sophia.com:32089/admin"
echo "   - Or via Ingress: http://myfirstgitapp.local/auth/admin"
echo "   - Clients → myapp-client → Settings"
echo "   - Add Redirect URI: https://olite.hd.free.fr/libertyX/callback/keycloak"
echo "   - Save"
echo ""
echo "3. Test the application:"
echo "   - Local: http://myfirstgitapp.local/libertyX/"
echo "   - Public: https://olite.hd.free.fr/libertyX/"
echo ""
echo "4. Keycloak Admin Console will be available at:"
echo "   - Public: https://olite.hd.free.fr/auth/admin"
echo ""
