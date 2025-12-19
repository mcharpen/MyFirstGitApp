#!/bin/bash
set -e

echo "Switching to k8s directory..."
cd k8s || exit 1

echo "Applying Namespace..."
kubectl apply -f namespace.yaml

echo "Applying ConfigMaps..."
kubectl apply -f nginx-configmap-fixed.yaml

echo "Applying Services and Deployments..."
kubectl apply -f nginx.yaml
kubectl apply -f keycloak.yaml
kubectl apply -f frontend.yaml

echo "Handling Ingress Conflicts..."
# Delete conflicting ingress in default namespace if it exists
echo "Deleting potential conflicting ingress in default namespace..."
kubectl delete ingress myfirstgitapp -n default --ignore-not-found=true
kubectl delete ingress myapp-ingress -n default --ignore-not-found=true

echo "Applying Ingress..."
if [ -f "ingress.yaml" ]; then
    kubectl apply -f ingress.yaml
fi
if [ -f "myapp-ingress.yaml" ]; then
    kubectl apply -f myapp-ingress.yaml
fi

echo "Restarting deployments in namespace 'myfirstgitapp'..."
kubectl rollout restart deployment/keycloak -n myfirstgitapp
kubectl rollout restart deployment/frontend -n myfirstgitapp
kubectl rollout restart deployment/nginx -n myfirstgitapp

echo "Checking status..."
kubectl get pods -n myfirstgitapp

echo "Done! Please wait for pods to be Ready."
