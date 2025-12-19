#!/bin/bash

set -e

echo "======================================"
echo "Fixing Nginx to pass full path to Keycloak"
echo "======================================"

echo ""
echo "Creating updated Nginx ConfigMap..."

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-conf
  namespace: default
data:
  nginx.conf: |
    user nginx;
    worker_processes auto;
    error_log /var/log/nginx/error.log warn;
    pid /var/run/nginx.pid;
    events { worker_connections 1024; }
    http {
      include /etc/nginx/mime.types;
      default_type application/octet-stream;
      sendfile on; keepalive_timeout 65;
      server {
        listen 80;
        server_name _;
        
        # Redirect /libertyX to /libertyX/
        location = /libertyX { return 301 /libertyX/; }
        
        # Keycloak proxy at /libertyX/auth (pass full path to Keycloak)
        location /libertyX/auth/ {
          proxy_pass http://keycloak.myfirstgitapp.svc.cluster.local:8080;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_buffer_size 128k;
          proxy_buffers 4 256k;
          proxy_busy_buffers_size 256k;
        }
        
        # API (NextAuth) under /api → Next.js at /libertyX/api/
        location /api/ {
          proxy_pass http://frontend.myfirstgitapp.svc.cluster.local:3000/libertyX/api/;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Backend emp endpoints (supports bare /emp and /libertyX/emp)
        location = /emp { 
          proxy_pass http://backend.myfirstgitapp.svc.cluster.local:8080/emp;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        location /libertyX/emp { 
          proxy_pass http://backend.myfirstgitapp.svc.cluster.local:8080/emp;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Frontend app at /libertyX/
        location /libertyX/ {
          proxy_pass http://frontend.myfirstgitapp.svc.cluster.local:3000/;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Redirect root to /libertyX/
        location = / { return 301 /libertyX/; }
      }
    }
EOF

echo ""
echo "Reloading Nginx..."
kubectl rollout restart deployment/nginx-deployment -n default
kubectl rollout status deployment/nginx-deployment -n default --timeout=60s

echo ""
echo "Waiting 5 seconds for Nginx to stabilize..."
sleep 5

echo ""
echo "======================================"
echo "Testing Keycloak endpoints..."
echo "======================================"

echo ""
echo "1. Testing OpenID configuration:"
curl -s http://myfirstgitapp.local/libertyX/auth/realms/myapp/.well-known/openid-configuration | jq -r '.issuer' || echo "Failed"

echo ""
echo "2. Testing admin console:"
curl -I http://myfirstgitapp.local/libertyX/auth/admin/ 2>&1 | grep -E "(HTTP|Location)" | head -5 || echo "Failed"

echo ""
echo "======================================"
echo "Fix complete!"
echo "======================================"
echo ""
echo "Expected issuer: http://myfirstgitapp.local/libertyX/auth/realms/myapp"
echo ""
echo "Next steps:"
echo "1. Test: http://myfirstgitapp.local/libertyX/auth/realms/myapp/.well-known/openid-configuration"
echo "2. Test: http://myfirstgitapp.local/libertyX/api/auth/providers"
echo "3. Test login: http://myfirstgitapp.local/libertyX/"
