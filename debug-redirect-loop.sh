#!/bin/bash

echo "======================================"
echo "Debugging Redirect Loop"
echo "======================================"
echo ""

# Test the redirect chain
echo "1. Testing redirect chain for https://olite.hd.free.fr/libertyX/"
echo "   (Following up to 5 redirects)"
curl -sI -L --max-redirs 5 https://olite.hd.free.fr/libertyX/ | grep -E "HTTP|Location:"
echo ""

# Test without following redirects
echo "2. Testing without following redirects:"
curl -sI https://olite.hd.free.fr/libertyX/ | grep -E "HTTP|Location:"
echo ""

# Check if there's a redirect at the root
echo "3. Testing root path:"
curl -sI https://olite.hd.free.fr/ | grep -E "HTTP|Location:"
echo ""

# Check Nginx configuration for potential redirect loops
echo "4. Checking Nginx pod logs for errors:"
NGINX_POD=$(kubectl get pods -n default -l app=nginx -o jsonpath='{.items[0].metadata.name}')
if [ -n "$NGINX_POD" ]; then
  echo "   Last 20 lines of Nginx error log:"
  kubectl logs -n default $NGINX_POD --tail=20 | grep -i error || echo "   No errors found"
else
  echo "   ❌ Nginx pod not found"
fi
echo ""

# Check the Nginx config for redirect rules
echo "5. Checking Nginx config for redirect rules:"
kubectl get configmap nginx-conf -n default -o jsonpath='{.data.nginx\.conf}' | grep -A2 "location.*libertyX"
echo ""

echo "======================================"
echo "Analysis Tips:"
echo "======================================"
echo "- If you see multiple 301/302 redirects to the same URL, there's a loop"
echo "- Check if HTTPS is being downgraded to HTTP and then upgraded again"
echo "- Verify that X-Forwarded-Proto is being passed correctly"
echo "- Check if there's a redirect from /libertyX/ back to /libertyX/"
echo ""
