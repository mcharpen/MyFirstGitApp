#!/bin/bash

# Debug OAuth flow issues in the browser

echo "=== Current Keycloak Client Configuration ==="
KC_POD=$(kubectl get pod -n myfirstgitapp -l app=keycloak -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080/libertyX/auth \
  --realm master \
  --user admin \
  --password admin > /dev/null 2>&1

CLIENT_ID=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients -r myapp -q clientId=myapp-client --fields id --format csv --noquotes)
echo ""
echo "Redirect URIs:"
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients/$CLIENT_ID -r myapp --fields redirectUris | grep -A 20 redirectUris

echo ""
echo "Web Origins:"
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients/$CLIENT_ID -r myapp --fields webOrigins | grep -A 20 webOrigins

echo ""
echo "=== Testing NextAuth Endpoints ==="
echo ""
echo "1. Testing /libertyX/api/auth/providers:"
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers | jq .

echo ""
echo "2. Testing /libertyX/api/auth/csrf:"
curl -s https://olite.hd.free.fr/libertyX/api/auth/csrf | jq .

echo ""
echo "=== Live Logs (Press Ctrl+C to stop) ==="
echo "Opening logs for Nginx, Frontend, and Keycloak..."
echo "Now try to log in with your browser and watch the logs below:"
echo ""

# Tail logs from all relevant pods
kubectl logs -n default -l app=nginx -f --tail=10 &
NGINX_PID=$!

kubectl logs -n myfirstgitapp -l app=frontend -f --tail=10 &
FRONTEND_PID=$!

kubectl logs -n myfirstgitapp -l app=keycloak -f --tail=10 &
KEYCLOAK_PID=$!

# Wait for user to stop
wait

# Clean up background processes
kill $NGINX_PID $FRONTEND_PID $KEYCLOAK_PID 2>/dev/null
