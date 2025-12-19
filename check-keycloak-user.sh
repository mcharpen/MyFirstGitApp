#!/bin/bash

# Check Keycloak user configuration for mcharpen

KC_POD=$(kubectl get pod -n myfirstgitapp -l app=keycloak -o jsonpath='{.items[0].metadata.name}')

echo "=== Configuring kcadm.sh ==="
# Note: Even though KC_HTTP_RELATIVE_PATH is set, we access Keycloak at root from inside the pod
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080/libertyX/auth \
  --realm master \
  --user admin \
  --password admin

echo ""
echo "=== Getting user 'mcharpen' details ==="
kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get users -r myapp -q username=mcharpen

echo ""
echo "=== Checking if user needs to reset password ==="
USER_ID=$(kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get users -r myapp -q username=mcharpen --fields id --format csv --noquotes)
echo "User ID: $USER_ID"

if [ -n "$USER_ID" ]; then
  echo ""
  echo "=== Getting user credentials info ==="
  kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh get users/$USER_ID -r myapp --fields enabled,emailVerified,credentials
  
  echo ""
  echo "=== Resetting password to 'mypassword' (not temporary) ==="
  kubectl exec -n myfirstgitapp $KC_POD -- /opt/keycloak/bin/kcadm.sh set-password -r myapp --username mcharpen --new-password mypassword
  
  echo ""
  echo "Password reset successful!"
else
  echo "User 'mcharpen' not found!"
fi
