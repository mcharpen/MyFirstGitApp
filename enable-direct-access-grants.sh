#!/bin/bash

# Enable Direct Access Grants for myapp-client

KC_POD=$(kubectl get pod -n myfirstgitapp -l app=keycloak -o jsonpath='{.items[0].metadata.name}')

echo "=== Configuring kcadm.sh ==="
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080/libertyX/auth \
  --realm master \
  --user admin \
  --password admin

echo ""
echo "=== Getting client ID ==="
CLIENT_ID=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients -r myapp -q clientId=myapp-client --fields id --format csv --noquotes)
echo "Client ID: $CLIENT_ID"

echo ""
echo "=== Enabling Direct Access Grants for myapp-client ==="
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh update clients/$CLIENT_ID \
  -r myapp \
  -s directAccessGrantsEnabled=true

echo ""
echo "=== Verifying configuration ==="
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients/$CLIENT_ID \
  -r myapp \
  --fields clientId,directAccessGrantsEnabled

echo ""
echo "✅ Direct Access Grants enabled successfully!"
