#!/bin/bash

echo "======================================"
echo "Checking Certificate and Testing Access"
echo "======================================"
echo ""

# Check certificate status
echo "1. Checking TLS certificate status:"
kubectl get certificate -n myfirstgitapp
echo ""

# Check certificate details
echo "2. Certificate details:"
kubectl describe certificate myfirstgitapp-tls -n myfirstgitapp | grep -A5 "Status:"
echo ""

# Check if secret exists
echo "3. Checking if TLS secret exists:"
kubectl get secret myfirstgitapp-tls -n myfirstgitapp 2>/dev/null && echo "✓ Secret exists" || echo "❌ Secret not found (certificate may still be issuing)"
echo ""

# Wait a moment for cert-manager to process
echo "4. Waiting 10 seconds for cert-manager..."
sleep 10
echo ""

# Test the URL
echo "5. Testing https://olite.hd.free.fr/libertyX/ (max 3 redirects):"
curl -sI -L --max-redirs 3 https://olite.hd.free.fr/libertyX/ 2>&1 | head -20
echo ""

echo "6. Testing if we can reach the page:"
curl -s --max-redirs 10 https://olite.hd.free.fr/libertyX/ 2>&1 | head -50
echo ""

echo "======================================"
echo "If you still see redirect loops, the issue might be:"
echo "- Certificate not ready yet (wait a few minutes)"
echo "- Next.js redirecting HTTP to HTTPS even when behind HTTPS proxy"
echo "- Missing X-Forwarded-Proto header handling"
echo "======================================"
