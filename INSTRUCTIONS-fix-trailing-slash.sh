#!/bin/bash

echo "======================================"
echo "Instructions to Fix Trailing Slash Issue"
echo "======================================"
echo ""
echo "The Next.js config has been updated with 'trailingSlash: true'"
echo "to prevent the redirect loop."
echo ""
echo "To apply this fix, you need to:"
echo ""
echo "1. Copy the updated next.config.js to your dev2 server:"
echo "   scp frontend/next.config.js dev2:~/GIT/MyFirstGitApp/frontend/"
echo ""
echo "2. SSH to dev2 and rebuild the frontend:"
echo "   ssh dev2"
echo "   cd ~/GIT/MyFirstGitApp/frontend"
echo "   docker build -t mcharpen/myfirstgitapp-frontend:trailingslash-fix ."
echo "   docker push mcharpen/myfirstgitapp-frontend:trailingslash-fix"
echo ""
echo "3. Update the deployment:"
echo "   kubectl set image deployment/frontend -n myfirstgitapp \\"
echo "     frontend=mcharpen/myfirstgitapp-frontend:trailingslash-fix"
echo ""
echo "4. Wait for rollout and test:"
echo "   kubectl rollout status deployment/frontend -n myfirstgitapp"
echo "   curl -sI -L --max-redirs 5 https://olite.hd.free.fr/libertyX/"
echo ""
echo "======================================"
echo ""
echo "Or, if you're already on dev2, just run these commands:"
echo ""
cat << 'EOF'
cd ~/GIT/MyFirstGitApp/frontend
docker build -t mcharpen/myfirstgitapp-frontend:trailingslash-fix .
docker push mcharpen/myfirstgitapp-frontend:trailingslash-fix
kubectl set image deployment/frontend -n myfirstgitapp frontend=mcharpen/myfirstgitapp-frontend:trailingslash-fix
kubectl rollout status deployment/frontend -n myfirstgitapp
sleep 10
curl -sI -L --max-redirs 5 https://olite.hd.free.fr/libertyX/
EOF
