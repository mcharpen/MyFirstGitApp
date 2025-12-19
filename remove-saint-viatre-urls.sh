#!/bin/bash

# Remove saint-viatre URLs and update Keycloak client with only the current URLs

KC_POD=$(kubectl get pod -n myfirstgitapp -l app=keycloak -o jsonpath='{.items[0].metadata.name}')

echo "=== Configuring kcadm.sh ==="
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080/libertyX/auth \
  --realm master \
  --user admin \
  --password admin

echo ""
echo "=== Getting current client configuration ==="
CLIENT_ID=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients -r myapp -q clientId=myapp-client --fields id --format csv --noquotes)
echo "Client ID: $CLIENT_ID"

echo ""
echo "Current configuration:"
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients/$CLIENT_ID -r myapp --fields redirectUris,webOrigins

echo ""
echo "=== Updating myapp-client to remove saint-viatre URLs ==="
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh update clients/$CLIENT_ID \
  -r myapp \
  -s 'redirectUris=["http://myfirstgitapp.local/libertyX/*","http://myfirstgitapp.local/libertyX/api/auth/*","https://olite.hd.free.fr/libertyX/*","https://olite.hd.free.fr/libertyX/api/auth/*"]' \
  -s 'webOrigins=["http://myfirstgitapp.local","https://olite.hd.free.fr"]'

echo ""
echo "=== Verifying updated configuration ==="
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients/$CLIENT_ID -r myapp --fields redirectUris,webOrigins

echo ""
echo "✅ Configuration updated successfully! saint-viatre URLs removed."
