#!/bin/bash

echo "======================================"
echo "Updating Keycloak Client Redirect URIs"
echo "======================================"

# Get Keycloak pod name
KEYCLOAK_POD=$(kubectl get pods -n myfirstgitapp -l app=keycloak -o jsonpath='{.items[0].metadata.name}')

if [ -z "$KEYCLOAK_POD" ]; then
  echo "❌ Error: Keycloak pod not found"
  exit 1
fi

echo "✓ Found Keycloak pod: $KEYCLOAK_POD"
echo ""

# Log into Keycloak CLI
echo "1. Logging into Keycloak admin..."
kubectl exec -n myfirstgitapp $KEYCLOAK_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080/libertyX/auth \
  --realm master \
  --user admin \
  --password admin

if [ $? -ne 0 ]; then
  echo "❌ Failed to login to Keycloak"
  exit 1
fi

echo "✓ Logged in successfully"
echo ""

# Get the client ID
echo "2. Getting client internal ID..."
CLIENT_ID=$(kubectl exec -n myfirstgitapp $KEYCLOAK_POD -- \
  /opt/keycloak/bin/kcadm.sh get clients -r myapp --fields id,clientId | \
  grep -B1 '"clientId" : "myapp-client"' | grep '"id"' | sed 's/.*"id" : "\([^"]*\)".*/\1/')

if [ -z "$CLIENT_ID" ]; then
  echo "❌ Failed to get client ID"
  exit 1
fi

echo "✓ Client ID: $CLIENT_ID"
echo ""

# Update redirect URIs (removing /libertyX from callback path)
echo "3. Updating redirect URIs..."
kubectl exec -n myfirstgitapp $KEYCLOAK_POD -- \
  /opt/keycloak/bin/kcadm.sh update clients/$CLIENT_ID -r myapp \
  -s 'redirectUris=["https://olite.hd.free.fr/api/auth/callback/keycloak","https://saint-viatre.hd.free.fr/api/auth/callback/keycloak","http://myfirstgitapp.local/api/auth/callback/keycloak","http://localhost:3000/api/auth/callback/keycloak"]'

if [ $? -eq 0 ]; then
  echo "✓ Redirect URIs updated successfully"
else
  echo "❌ Failed to update redirect URIs"
  exit 1
fi

echo ""

# Update web origins
echo "4. Updating web origins..."
kubectl exec -n myfirstgitapp $KEYCLOAK_POD -- \
  /opt/keycloak/bin/kcadm.sh update clients/$CLIENT_ID -r myapp \
  -s 'webOrigins=["https://olite.hd.free.fr","https://saint-viatre.hd.free.fr","http://myfirstgitapp.local","http://localhost:3000"]'

if [ $? -eq 0 ]; then
  echo "✓ Web origins updated successfully"
else
  echo "❌ Failed to update web origins"
  exit 1
fi

echo ""

# Verify the changes
echo "5. Verifying client configuration..."
kubectl exec -n myfirstgitapp $KEYCLOAK_POD -- \
  /opt/keycloak/bin/kcadm.sh get clients/$CLIENT_ID -r myapp --fields clientId,redirectUris,webOrigins

echo ""
echo "======================================"
echo "✓ Keycloak client updated successfully!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Test the login flow at https://olite.hd.free.fr/libertyX/"
echo "2. Verify callback works at /api/auth/callback/keycloak"
echo ""
