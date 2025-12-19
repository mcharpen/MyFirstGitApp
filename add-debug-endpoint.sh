#!/bin/bash

echo "=== Debugging Nginx header values ==="

# Add a debug endpoint to show all variables
cat > /tmp/debug-nginx.conf << 'EOF'
        # Debug endpoint to show variable values
        location = /debug-headers {
            add_header Content-Type text/plain;
            return 200 "host: $host\nscheme: $scheme\nhttp_x_forwarded_host: $http_x_forwarded_host\nhttp_x_forwarded_proto: $http_x_forwarded_proto\nforwarded_host: $forwarded_host\nforwarded_proto: $forwarded_proto\n";
        }
EOF

# Get current nginx config
kubectl get configmap nginx-conf -n default -o jsonpath='{.data.nginx\.conf}' > /tmp/current-nginx.conf

# Add debug endpoint before the health endpoint
sed -i '/location = \/health/i\        # Debug endpoint to show variable values\n        location = \/debug-headers {\n            add_header Content-Type text\/plain;\n            return 200 "host: $host\\nscheme: $scheme\\nhttp_x_forwarded_host: $http_x_forwarded_host\\nhttp_x_forwarded_proto: $http_x_forwarded_proto\\nforwarded_host: $forwarded_host\\nforwarded_proto: $forwarded_proto\\n";\n        }\n' /tmp/current-nginx.conf

# Update the configmap
kubectl create configmap nginx-conf --from-file=nginx.conf=/tmp/current-nginx.conf -n default --dry-run=client -o yaml | kubectl apply -f -

# Restart pods
kubectl delete pod -n default -l app=nginx

echo "Waiting for pods..."
sleep 10

echo ""
echo "Testing debug endpoint:"
curl -s https://olite.hd.free.fr/debug-headers
