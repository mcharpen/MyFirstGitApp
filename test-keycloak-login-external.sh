#!/bin/bash

# Test Keycloak login from outside the cluster using the public URL

echo "=== Testing login for user 'mcharpen' with password 'mypassword' ==="
echo ""

KC_POD=$(kubectl get pod -n myfirstgitapp -l app=keycloak -o jsonpath='{.items[0].metadata.name}')

echo "Getting client secret for myapp-client..."
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080/libertyX/auth \
  --realm master \
  --user admin \
  --password admin > /dev/null 2>&1

CLIENT_ID=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients -r myapp -q clientId=myapp-client --fields id --format csv --noquotes)
CLIENT_SECRET=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients/$CLIENT_ID -r myapp --fields secret | grep -o '"secret" : "[^"]*"' | cut -d'"' -f4)

echo "Client ID: myapp-client"
echo "Client Secret: $CLIENT_SECRET"
echo ""

echo "Attempting to get access token using password grant..."
RESPONSE=$(curl -s -X POST "https://olite.hd.free.fr/libertyX/auth/realms/myapp/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=myapp-client" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "grant_type=password" \
  -d "username=mcharpen" \
  -d "password=mypassword")

echo "Response:"
echo "$RESPONSE" | jq .

if echo "$RESPONSE" | jq -e '.access_token' > /dev/null 2>&1; then
  echo ""
  echo "✅ SUCCESS! Login with mcharpen/mypassword works!"
  echo ""
  echo "Access Token (first 50 chars):"
  echo "$RESPONSE" | jq -r '.access_token' | cut -c1-50
else
  echo ""
  echo "❌ FAILED! Login with mcharpen/mypassword did not work."
  echo ""
  if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    echo "Error: $(echo "$RESPONSE" | jq -r '.error_description // .error')"
  fi
fi
