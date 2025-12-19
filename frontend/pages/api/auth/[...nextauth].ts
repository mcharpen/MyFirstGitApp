import NextAuth from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";
import { NextApiRequest, NextApiResponse } from "next";

export default async function auth(req: NextApiRequest, res: NextApiResponse) {
  // Use the internal Kubernetes DNS name for Keycloak
  const keycloakIssuer = "http://keycloak.myfirstgitapp.svc.cluster.local:8080/libertyX/auth/realms/myapp";

  console.log('[NextAuth] Using Keycloak issuer:', keycloakIssuer);

  return await NextAuth(req, res, {
    providers: [
      KeycloakProvider({
        clientId: process.env.KEYCLOAK_CLIENT_ID || "",
        clientSecret: process.env.KEYCLOAK_CLIENT_SECRET || "",
        issuer: keycloakIssuer,
        checks: ['pkce', 'state'],
      }),
    ],
    secret: process.env.NEXTAUTH_SECRET,
    pages: {
      error: '/api/auth/error',
    },
    callbacks: {
      async redirect({ url, baseUrl: callbackBaseUrl }) {
        if (url.startsWith("/")) return `${callbackBaseUrl}/libertyX${url}`;
        else if (new URL(url).origin === callbackBaseUrl) return url;
        return `${callbackBaseUrl}/libertyX`;
      },
    },
    debug: true,
  });
}