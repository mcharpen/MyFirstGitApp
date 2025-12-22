#!/bin/bash
# Deploy Keycloak with public HTTPS access via Ingress

set -e

echo "=== Deploying Keycloak with Public HTTPS Access ==="
echo ""

echo "Step 1: Delete existing Keycloak pod to force realm reimport"
kubectl delete pod -n myfirstgitapp -l app=keycloak
echo "✓ Keycloak pod deleted"
echo ""

echo "Step 2: Applying Keycloak configuration with /auth base path and updated realm"
kubectl apply -f k8s/keycloak.yaml
echo "✓ Keycloak configuration applied"
echo ""

echo "Step 3: Waiting for Keycloak to be ready (this may take 30-60 seconds)..."
kubectl wait --for=condition=ready pod -l app=keycloak -n myfirstgitapp --timeout=120s
sleep 15
echo "✓ Keycloak is ready"
echo ""

echo "Step 4: Testing Keycloak at /auth path..."
echo "Checking: http://keycloak.myfirstgitapp.svc.cluster.local:8080/auth/realms/myapp/.well-known/openid-configuration"
kubectl run -it --rm test-keycloak --image=curlimages/curl --restart=Never -- \
  curl -s http://keycloak.myfirstgitapp.svc.cluster.local:8080/auth/realms/myapp/.well-known/openid-configuration \
  | grep -q issuer && echo "✓ Keycloak /auth path is working" || echo "✗ Keycloak /auth path NOT working"
echo ""

echo "Step 5: Updating internal Nginx to proxy Keycloak at /auth"
kubectl apply -f ansible/nginx-ingress.yml
kubectl rollout restart deployment/nginx-deployment -n default
kubectl rollout status deployment/nginx-deployment -n default
echo "✓ Internal Nginx updated"
echo ""

echo "Step 6: Testing Keycloak via Ingress..."
sleep 5
curl -s http://myfirstgitapp.local/auth/realms/myapp/.well-known/openid-configuration | grep -q issuer && \
  echo "✓ Keycloak is accessible via Ingress at /auth" || \
  echo "✗ Keycloak is NOT accessible via Ingress (check nginx logs)"
echo ""

echo "Step 7: Updating frontend with public Keycloak URL"
kubectl apply -f k8s/frontend.yaml
kubectl rollout restart deployment/frontend -n myfirstgitapp
kubectl rollout status deployment/frontend -n myfirstgitapp
echo "✓ Frontend configuration updated"
echo ""

echo "=== Verifying Final Configuration ==="
echo ""
echo "Frontend KEYCLOAK_ISSUER:"
kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].spec.containers[0].env[?(@.name=="KEYCLOAK_ISSUER")].value}'
echo ""
echo ""
echo "Frontend NEXTAUTH_URL:"
kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].spec.containers[0].env[?(@.name=="NEXTAUTH_URL")].value}'
echo ""
echo ""

echo "=== Next Steps ==="
echo ""
echo "1. Update external Nginx on olite.hd.free.fr with the config from external-nginx-config.conf"
echo "   sudo nano /etc/nginx/sites-available/olite"
echo "   sudo nginx -t"
echo "   sudo systemctl reload nginx"
echo ""
echo "2. Test the application:"
echo "   - Local: http://myfirstgitapp.local/libertyX/"
echo "   - Public: https://olite.hd.free.fr/libertyX/"
echo ""
echo "3. Keycloak Admin Console:"
echo "   - Via NodePort: http://dev2.sophia.com:32089/auth/admin"
echo "   - Via Ingress (local): http://myfirstgitapp.local/auth/admin"
echo "   - Public (after external nginx): https://olite.hd.free.fr/auth/admin"
echo ""
echo "If there are issues, check logs:"
echo "  kubectl logs -n myfirstgitapp -l app=keycloak --tail=50"
echo "  kubectl logs -n default -l app=nginx --tail=50"
echo "  kubectl logs -n myfirstgitapp -l app=frontend --tail=50"
echo ""
