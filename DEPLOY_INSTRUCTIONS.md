# Deployment Instructions

## Changes Made
- Updated `frontend/pages/_app.tsx` to add `basePath="/libertyX/api/auth"` to SessionProvider
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
