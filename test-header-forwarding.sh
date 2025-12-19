#!/bin/bash

echo "=== Testing header forwarding from Ingress to Nginx ==="
echo ""

NGINX_POD=$(kubectl get pod -n default -l app=nginx -o jsonpath='{.items[0].metadata.name}' | grep Running || kubectl get pod -n default -l app=nginx -o jsonpath='{.items[0].metadata.name}')

echo "Nginx pod: $NGINX_POD"
echo ""

echo "1. Creating a test endpoint in Nginx to echo headers..."
kubectl exec -n default $NGINX_POD -- sh -c 'cat > /tmp/test-headers.conf << EOF
server {
    listen 8888;
    location /test-headers {
        default_type text/plain;
        return 200 "Host: \$host\nX-Forwarded-Host: \$http_x_forwarded_host\nX-Forwarded-Proto: \$http_x_forwarded_proto\nX-Forwarded-For: \$http_x_forwarded_for\n";
    }
}
EOF'

echo ""
echo "2. Testing via external URL (through Ingress)..."
curl -s https://olite.hd.free.fr/libertyX/api/auth/providers 2>&1 | head -5

echo ""
echo "3. Checking frontend logs for received headers..."
kubectl logs -n myfirstgitapp deployment/frontend --tail=30 | grep "Request headers" -A 7 | tail -10

echo ""
echo "Done!"
