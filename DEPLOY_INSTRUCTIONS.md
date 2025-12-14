# Deployment Instructions

## Changes Made
- Updated `frontend/pages/_app.tsx` to add `basePath="/libertyX/api/auth"` to SessionProvider
- Updated `frontend/pages/api/auth/[...nextauth].ts` to add error page configuration and debug mode
- Created `frontend/pages/error.tsx` for better error display
- This ensures NextAuth uses correct paths with the `/libertyX` basePath

## Deploy Steps (Run on dev2 Kubernetes server)

### 1. Rebuild and Push Frontend Image
```bash
cd /path/to/MyFirstGitApp/frontend
docker build -t mcharpen5/myfirstapp-frontend:latest .
docker push mcharpen5/myfirstapp-frontend:latest
```

### 2. Restart Frontend Deployment
```bash
kubectl rollout restart deploy/frontend -n myfirstgitapp
kubectl rollout status deploy/frontend -n myfirstgitapp
```

### 3. Verify the Fix
```bash
# Check that NextAuth providers return correct URLs with /libertyX
curl https://olite.hd.free.fr/libertyX/api/auth/providers
```

Expected output should show URLs like:
```json
{
  "keycloak": {
    "id": "keycloak",
    "name": "Keycloak",
    "type": "oauth",
    "signinUrl": "https://olite.hd.free.fr/libertyX/api/auth/signin/keycloak",
    "callbackUrl": "https://olite.hd.free.fr/libertyX/api/auth/callback/keycloak"
  }
}
```

### 4. Test Login
1. Open browser: https://olite.hd.free.fr/libertyX/
2. Click "Login with Keycloak"
3. Should redirect to Keycloak login (dev2.sophia.com:32089)
4. After login, should redirect back to https://olite.hd.free.fr/libertyX/

### 5. Update Keycloak Client (if not done already)
Make sure the Keycloak client has these Redirect URIs:
- `https://olite.hd.free.fr/libertyX/*`
- `https://olite.hd.free.fr/libertyX/api/auth/callback/keycloak`

And Web Origins:
- `https://olite.hd.free.fr`

## Troubleshooting OAuthSignin Error

If you see `OAuthSignin` error, check:

### 1. Verify Keycloak is accessible from frontend pod
```bash
kubectl exec -it -n myfirstgitapp deploy/frontend -- curl -v http://dev2.sophia.com:32089/realms/myapp/.well-known/openid-configuration
```

### 2. Check frontend logs for detailed error
```bash
kubectl logs -n myfirstgitapp -l app=frontend --tail=100
```

### 3. Verify environment variables
```bash
kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].spec.containers[0].env[?(@.name=="KEYCLOAK_ISSUER")].value}'
kubectl get pod -n myfirstgitapp -l app=frontend -o jsonpath='{.items[0].spec.containers[0].env[?(@.name=="NEXTAUTH_URL")].value}'
```

### 4. Check Keycloak client secret
```bash
kubectl get secret -n myfirstgitapp frontend-secrets -o jsonpath='{.data.KEYCLOAK_CLIENT_SECRET}' | base64 -d
```
Compare with Keycloak Admin Console: Clients → myapp-client → Credentials

### 5. If Keycloak is not accessible from pods
The issue might be that `dev2.sophia.com:32089` is not resolvable/accessible from within the cluster. 

**Option A**: Use cluster-internal service URL:
```bash
# Update frontend.yaml KEYCLOAK_ISSUER to:
KEYCLOAK_ISSUER: http://keycloak.myfirstgitapp.svc.cluster.local:8080/realms/myapp
```

**Option B**: Expose Keycloak via Ingress and use that URL
