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
    'NEXTAUTH_URL (env)': process.env.NEXTAUTH_URL,
    'full-headers': JSON.stringify(req.headers, null, 2)
  });

  return await NextAuth(req, res, {
    providers: [
      KeycloakProvider({
        clientId: process.env.KEYCLOAK_CLIENT_ID || "",
        clientSecret: process.env.KEYCLOAK_CLIENT_SECRET || "",
        issuer: process.env.KEYCLOAK_ISSUER,
        checks: ['pkce', 'state'],
      }),
    ],
    secret: process.env.NEXTAUTH_SECRET,
    pages: {
      error: '/api/auth/error', // Error page (no basePath for API routes!)
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
    debug: true, // Enable debug mode to see more error details
  });
} 