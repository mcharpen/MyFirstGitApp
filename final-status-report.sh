#!/bin/bash

echo "=================================================================="
echo "Migration to Kubernetes - Final Status Report"
echo "=================================================================="
echo ""
echo "Date: $(date)"
echo ""

echo "=== 1. INFRASTRUCTURE STATUS ==="
echo ""
echo "Namespaces:"
kubectl get ns | grep -E "NAME|myfirstgitapp|default"
echo ""

echo "All Pods:"
kubectl get pods -n myfirstgitapp
kubectl get pods -n default -l app=nginx
echo ""

echo "All Services:"
kubectl get svc -n myfirstgitapp
kubectl get svc -n default | grep nginx
echo ""

echo "Ingress Resources:"
kubectl get ingress -A
echo ""

echo "Certificate Status:"
kubectl get certificate -n default
echo ""

echo "=== 2. CONFIGURATION SUMMARY ==="
echo ""
echo "✓ Frontend: Next.js with basePath '/libertyX' (no trailingSlash)"
echo "✓ Backend: Quarkus at /emp endpoint"
echo "✓ Keycloak: Running at /libertyX/auth"
echo "✓ PostgreSQL: Database backend"
echo "✓ Nginx: Reverse proxy in default namespace"
echo "✓ NextAuth: API routes at /api/auth/* (no basePath)"
echo "✓ NEXTAUTH_URL: https://olite.hd.free.fr"
echo "✓ Keycloak Client: redirect URIs updated to /api/auth/callback/keycloak"
echo ""

echo "=== 3. TESTING ENDPOINTS ==="
echo ""

echo "Test 1: Main application page"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://olite.hd.free.fr/libertyX/)
if [ "$HTTP_CODE" = "200" ]; then
  echo "✓ https://olite.hd.free.fr/libertyX/ - 200 OK"
else
  echo "✗ https://olite.hd.free.fr/libertyX/ - $HTTP_CODE"
fi
echo ""

echo "Test 2: Backend /emp endpoint"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://olite.hd.free.fr/emp)
if [ "$HTTP_CODE" = "200" ]; then
  echo "✓ https://olite.hd.free.fr/emp - 200 OK"
else
  echo "✗ https://olite.hd.free.fr/emp - $HTTP_CODE"
fi
echo ""

echo "Test 3: Keycloak well-known config"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://olite.hd.free.fr/libertyX/auth/realms/myapp/.well-known/openid-configuration)
if [ "$HTTP_CODE" = "200" ]; then
  echo "✓ https://olite.hd.free.fr/libertyX/auth/.well-known - 200 OK"
else
  echo "✗ https://olite.hd.free.fr/libertyX/auth/.well-known - $HTTP_CODE"
fi
echo ""

echo "Test 4: NextAuth providers endpoint"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://olite.hd.free.fr/api/auth/providers)
RESPONSE=$(curl -s https://olite.hd.free.fr/api/auth/providers | head -5)
if [[ "$RESPONSE" == *"keycloak"* ]]; then
  echo "✓ https://olite.hd.free.fr/api/auth/providers - Returns JSON"
else
  echo "✗ https://olite.hd.free.fr/api/auth/providers - $HTTP_CODE"
  echo "  Response: $RESPONSE"
fi
echo ""

echo "=== 4. KNOWN ISSUES ==="
echo ""
echo "Issue 1: TLS Certificate"
CERT_READY=$(kubectl get certificate myfirstgitapp-tls -n default -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
if [ "$CERT_READY" = "True" ]; then
  echo "✓ TLS certificate is ready"
else
  echo "⚠ TLS certificate is still being issued (takes 2-5 minutes)"
  echo "  Check status: kubectl get certificate -n default"
  echo "  Once ready, all HTTPS endpoints should work correctly"
fi
echo ""

echo "=== 5. NEXT STEPS ==="
echo ""
echo "1. Wait for TLS certificate to be issued (check with: kubectl get certificate -n default)"
echo "2. Once certificate is ready, test the full login flow:"
echo "   - Go to: https://olite.hd.free.fr/libertyX/"
echo "   - Click the Keycloak login button"
echo "   - Login with Keycloak credentials"
echo "   - Verify callback works and you're logged in"
echo ""
echo "3. Update DNS if needed to point to the correct Ingress IP"
echo ""

echo "=== 6. FILES MODIFIED ==="
echo ""
echo "- /k8s/ingress.yaml (moved to default namespace, using letsencrypt-prod)"
echo "- /k8s/frontend.yaml (NEXTAUTH_URL fixed to https://olite.hd.free.fr)"
echo "- /k8s/nginx-configmap-fixed.yaml (/api/ routing, basePath stripping)"
echo "- /frontend/next.config.js (removed trailingSlash)"
echo "- /frontend/pages/api/auth/[...nextauth].ts (error page path fixed)"
echo "- Keycloak client: redirect URIs updated to /api/auth/callback/keycloak"
echo ""

echo "=================================================================="
echo "Report complete!"
echo "=================================================================="
