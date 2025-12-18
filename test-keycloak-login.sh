#!/bin/bash

# Test Keycloak login with mcharpen/mypassword

KC_POD=$(kubectl get pod -n myfirstgitapp -l app=keycloak -o jsonpath='{.items[0].metadata.name}')

echo "=== Testing login for user 'mcharpen' with password 'mypassword' ==="
echo ""

# Get the client secret first
echo "Getting client secret for myapp-client..."
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080/libertyX/auth \
  --realm master \
  --user admin \
  --password admin > /dev/null 2>&1

CLIENT_SECRET=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients -r myapp -q clientId=myapp-client --fields secret --format csv --noquotes 2>/dev/null | tail -1)

echo "Client Secret: $CLIENT_SECRET"
echo ""

# Try to get a token using the password grant type
echo "Attempting to get access token..."
TOKEN_RESPONSE=$(kubectl exec -n myfirstgitapp $KC_POD -- curl -s -X POST \
  "http://localhost:8080/libertyX/auth/realms/myapp/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=myapp-client" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "username=mcharpen" \
  -d "password=mypassword" \
  -d "scope=openid")

echo "$TOKEN_RESPONSE" | jq .

# Check if we got an access token
if echo "$TOKEN_RESPONSE" | jq -e '.access_token' > /dev/null 2>&1; then
  echo ""
  echo "✅ SUCCESS! Login with mcharpen/mypassword works!"
  echo ""
  echo "Access Token (first 50 chars):"
  echo "$TOKEN_RESPONSE" | jq -r '.access_token' | cut -c1-50
else
  echo ""
  echo "❌ FAILED! Login with mcharpen/mypassword did not work."
  echo ""
  echo "Error:"
  echo "$TOKEN_RESPONSE" | jq -r '.error_description // .error // "Unknown error"'
fi
