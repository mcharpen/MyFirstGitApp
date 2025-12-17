#!/bin/bash

echo "======================================"
echo "Testing API Routes (Run this on dev2)"
echo "======================================"
echo ""

echo "1. Test /api/auth/providers through Nginx service:"
kubectl run -n default test-api --image=curlimages/curl:latest --rm -i --restart=Never -- curl -v http://nginx.default.svc.cluster.local/api/auth/providers 2>&1 | grep -E "HTTP|Host:|Location:"
echo ""

echo "2. Test /api/auth/providers externally:"
curl -v https://olite.hd.free.fr/api/auth/providers 2>&1 | grep -E "HTTP|Host:|Location:"
echo ""

echo "3. Get frontend pod and check env vars:"
FRONTEND_POD=$(kubectl get pods -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].metadata.name}')
echo "Frontend Pod: $FRONTEND_POD"
echo ""
echo "Environment variables:"
kubectl exec -n myfirstgitapp $FRONTEND_POD -- env | grep -E "NEXTAUTH|KEYCLOAK" | sort
echo ""

echo "4. Check frontend logs for auth errors:"
kubectl logs -n myfirstgitapp deployment/frontend --tail=50 | grep -i "auth\|error" || echo "No auth errors in logs"
echo ""

echo "======================================"
