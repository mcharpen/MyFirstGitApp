import NextAuth from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";
import { NextApiRequest, NextApiResponse } from "next";

export default async function auth(req: NextApiRequest, res: NextApiResponse) {
  // Dynamically determine the base URL from the request
  // Check X-Forwarded-* headers first (set by Nginx/Ingress)
  const protocol = req.headers['x-forwarded-proto'] as string || 'http';
  const host = (req.headers['x-forwarded-host'] as string) || (req.headers.host as string) || 'localhost:3000';
  const baseUrl = `${protocol}://${host}`;

  console.log('[NextAuth] Request headers:', {
    'x-forwarded-proto': req.headers['x-forwarded-proto'],
    'x-forwarded-host': req.headers['x-forwarded-host'],
    'host': req.headers.host,
    'computed-baseUrl': baseUrl,
    'full-headers': JSON.stringify(req.headers, null, 2)
  });

  // Debug logging
  console.log("NextAuth Configuration:");
  console.log("ISSUER:", process.env.KEYCLOAK_ISSUER);
  console.log("NEXTAUTH_URL:", process.env.NEXTAUTH_URL);

  if (!process.env.KEYCLOAK_ISSUER) {
    throw new Error("Missing KEYCLOAK_ISSUER environment variable");
  }

  return await NextAuth(req, res, {
    providers: [
      KeycloakProvider({
        clientId: process.env.KEYCLOAK_CLIENT_ID || "myapp-client",
        clientSecret: process.env.KEYCLOAK_CLIENT_SECRET || "your-client-secret",
        issuer: process.env.KEYCLOAK_ISSUER,
      }),
    ],
    debug: true,
    pages: {
      signIn: '/libertyX/api/auth/signin',
      signOut: '/libertyX/api/auth/signout',
      error: '/libertyX/api/auth/error', // Force correct path for errors
    },
    callbacks: {
      async redirect({ url, baseUrl: callbackBaseUrl }) {
        console.log('[NextAuth] Redirect callback:', { url, callbackBaseUrl, computedBaseUrl: baseUrl });
        // Handle relative URLs
        if (url.startsWith("/")) return `${baseUrl}/libertyX${url}`;
        // Handle URLs from the same origin
        else if (new URL(url).origin === callbackBaseUrl) return url;
        return `${baseUrl}/libertyX`;
      },
    },
  });
}