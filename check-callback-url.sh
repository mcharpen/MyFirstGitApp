#!/bin/bash

# Check what callback URL NextAuth is generating

echo "=== Testing NextAuth Callback URL Generation ==="
echo ""

echo "1. Get CSRF token and session:"
CSRF_RESPONSE=$(curl -s -c /tmp/cookies.txt https://olite.hd.free.fr/libertyX/api/auth/csrf)
echo "CSRF Response:"
echo "$CSRF_RESPONSE" | jq .

CSRF_TOKEN=$(echo "$CSRF_RESPONSE" | jq -r '.csrfToken')
echo ""
echo "CSRF Token: $CSRF_TOKEN"

echo ""
echo "2. Initiate OAuth signin (this will give us the redirect URL):"
SIGNIN_RESPONSE=$(curl -s -b /tmp/cookies.txt -L -w "\n%{url_effective}" \
  https://olite.hd.free.fr/libertyX/api/auth/signin/keycloak)

echo "Final redirect URL:"
echo "$SIGNIN_RESPONSE" | tail -1

echo ""
echo "3. Extract callback URL from Keycloak authorization endpoint:"
AUTH_URL=$(echo "$SIGNIN_RESPONSE" | tail -1)
CALLBACK_URL=$(echo "$AUTH_URL" | grep -oP 'redirect_uri=\K[^&]*' | python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))")

echo "Callback URL that Keycloak will redirect to:"
echo "$CALLBACK_URL"

echo ""
echo "4. Check if this callback URL is allowed in Keycloak:"
KC_POD=$(kubectl get pod -n myfirstgitapp -l app=keycloak -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080/libertyX/auth \
  --realm master \
  --user admin \
  --password admin > /dev/null 2>&1

CLIENT_ID=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients -r myapp -q clientId=myapp-client --fields id --format csv --noquotes)

echo "Allowed redirect URIs in Keycloak:"
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients/$CLIENT_ID -r myapp --fields redirectUris | jq -r '.redirectUris[]'

echo ""
if [[ "$CALLBACK_URL" =~ ^https://olite\.hd\.free\.fr/libertyX/ ]]; then
  echo "✅ Callback URL matches the allowed pattern!"
else
  echo "❌ Callback URL does NOT match the allowed pattern!"
  echo "   Expected pattern: https://olite.hd.free.fr/libertyX/*"
  echo "   Actual URL: $CALLBACK_URL"
fi

rm -f /tmp/cookies.txt
