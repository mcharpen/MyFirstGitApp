#!/bin/bash

echo "======================================"
echo "Checking Nginx Deployment"
echo "======================================"
echo ""

echo "1. Checking deployments in default namespace..."
kubectl get deployments -n default

echo ""
echo ""
echo "2. Checking all resources with nginx label..."
kubectl get all -n default -l app=nginx-deployment

echo ""
echo ""
echo "3. Checking recent events..."
kubectl get events -n default --sort-by='.lastTimestamp' | tail -20

echo ""
echo ""
echo "4. Describing nginx deployment..."
kubectl describe deployment nginx-deployment -n default 2>&1 | tail -30

echo ""
