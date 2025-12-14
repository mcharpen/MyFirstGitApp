#!/bin/bash
# Quick fix script for Keycloak connectivity issue

set -e

echo "=== Fixing Keycloak Issuer URL ==="
echo ""
echo "Applying updated frontend configuration with internal Keycloak URL..."
kubectl apply -f k8s/frontend.yaml

echo ""
echo "Restarting frontend deployment..."
kubectl rollout restart deploy/frontend -n myfirstgitapp

echo ""
echo "Waiting for rollout to complete..."
kubectl rollout status deploy/frontend -n myfirstgitapp

echo ""
echo "=== Verifying Configuration ==="
echo "KEYCLOAK_ISSUER:"
kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].spec.containers[0].env[?(@.name=="KEYCLOAK_ISSUER")].value}'
echo ""
echo ""
echo "NEXTAUTH_URL:"
kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].spec.containers[0].env[?(@.name=="NEXTAUTH_URL")].value}'
echo ""
echo ""

echo "=== Testing Keycloak Connectivity ==="
echo "Waiting for pod to be ready..."
sleep 5

POD_NAME=$(kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].metadata.name}')
echo "Testing from pod: $POD_NAME"
kubectl exec -n myfirstgitapp $POD_NAME -- node -e "fetch('http://keycloak.myfirstgitapp.svc.cluster.local:8080/realms/myapp/.well-known/openid-configuration').then(r=>r.json()).then(d=>console.log('✓ Keycloak is accessible. Issuer:', d.issuer)).catch(e=>console.error('✗ Error:', e.message))"

echo ""
echo "=== Done! ==="
echo "Now test the login at: https://olite.hd.free.fr/libertyX/"
