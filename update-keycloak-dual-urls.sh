#!/bin/bash

# Update Keycloak client redirect URIs to support both local and public URLs

# Get Keycloak admin credentials
KC_POD=$(kubectl get pod -n myfirstgitapp -l app=keycloak -o jsonpath='{.items[0].metadata.name}')

echo "Getting admin token..."
ADMIN_TOKEN=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080 \
  --realm master \
  --user admin \
  --password admin 2>&1 | grep -v "Logging into" | grep -v "config credentials")

echo "Updating myapp-client redirect URIs..."
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh update clients/$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get clients -r myapp -q clientId=myapp-client --fields id --format csv --noquotes) \
  -r myapp \
  -s 'redirectUris=["http://myfirstgitapp.local/libertyX/*","http://myfirstgitapp.local/api/auth/*","https://olite.hd.free.fr/libertyX/*","https://olite.hd.free.fr/api/auth/*"]' \
  -s 'webOrigins=["http://myfirstgitapp.local","https://olite.hd.free.fr"]'

echo "Done! Redirect URIs updated to support both local and public URLs."
