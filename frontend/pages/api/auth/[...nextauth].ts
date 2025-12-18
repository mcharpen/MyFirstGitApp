import NextAuth from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";
import { NextApiRequest, NextApiResponse } from "next";

export default async function auth(req: NextApiRequest, res: NextApiResponse) {
  // Dynamically determine the base URL from the request
  const protocol = req.headers['x-forwarded-proto'] || 'http';
  const host = req.headers['x-forwarded-host'] || req.headers.host || 'localhost:3000';
  const baseUrl = `${protocol}://${host}`;
  
  // Build the Keycloak issuer URL dynamically
  const keycloakIssuer = `${baseUrl}/libertyX/auth/realms/myapp`;

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
      error: '/api/auth/error', // Error page (no basePath for API routes!)
    },
    callbacks: {
      async redirect({ url, baseUrl: callbackBaseUrl }) {
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