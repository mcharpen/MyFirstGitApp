#!/bin/bash

echo "======================================"
echo "Checking Nginx Access Logs"
echo "======================================"
echo ""

echo "Last 30 requests to the application:"
echo ""
kubectl exec -n default deployment/nginx-deployment -- tail -30 /var/log/nginx/access.log

echo ""
echo ""
echo "======================================"
echo "Filtering for 404 errors:"
echo ""
kubectl exec -n default deployment/nginx-deployment -- tail -100 /var/log/nginx/access.log | grep " 404 "

echo ""
echo ""
echo "======================================"
echo "Filtering for /api/auth/ requests:"
echo ""
kubectl exec -n default deployment/nginx-deployment -- tail -100 /var/log/nginx/access.log | grep "/api/auth/"

echo ""
