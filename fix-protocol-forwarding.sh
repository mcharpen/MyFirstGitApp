#!/bin/bash

echo "========================================="
echo "Fixing Protocol Forwarding for NextAuth"
echo "========================================="

# Step 1: Apply updated Nginx ConfigMap with forwarded_proto map
echo "Step 1: Applying updated Nginx ConfigMap..."
kubectl apply -f k8s/nginx-configmap-fixed.yaml
echo "✓ ConfigMap applied"

# Step 2: Restart Nginx to pick up new config
echo ""
echo "Step 2: Restarting Nginx pod..."
kubectl delete pod -n default -l app=nginx
echo "Waiting for new Nginx pod to be ready..."
kubectl wait --for=condition=ready pod -n default -l app=nginx --timeout=60s
echo "✓ Nginx restarted"

# Step 3: Rebuild and push frontend with updated NextAuth config
echo ""
echo "Step 3: Rebuilding frontend Docker image..."
cd frontend
docker build -t mcharpen/myfirstgitapp-frontend:latest .
echo "✓ Frontend image built"

echo ""
echo "Step 4: Pushing frontend image to Docker Hub..."
docker push mcharpen/myfirstgitapp-frontend:latest
echo "✓ Image pushed"
cd ..

# Step 5: Restart frontend pods to use new image
echo ""
echo "Step 5: Restarting frontend pods..."
kubectl rollout restart deployment/frontend -n myfirstgitapp
echo "Waiting for frontend rollout to complete..."
kubectl rollout status deployment/frontend -n myfirstgitapp --timeout=120s
echo "✓ Frontend restarted"

# Step 6: Test the headers
echo ""
echo "========================================="
echo "Testing header forwarding..."
echo "========================================="

# Wait a bit for everything to settle
sleep 5

echo ""
echo "Test 1: Check /api/auth/providers from public URL (should show https)"
echo "---"
curl -s "https://olite.hd.free.fr/api/auth/providers" | head -20

echo ""
echo ""
echo "Test 2: Check frontend logs for NextAuth headers"
echo "---"
kubectl logs -n myfirstgitapp deployment/frontend --tail=30 | grep -A 5 "NextAuth"

echo ""
echo "========================================="
echo "Done! Check the logs above for protocol detection."
echo "The baseUrl should now be https://olite.hd.free.fr"
echo "========================================="
