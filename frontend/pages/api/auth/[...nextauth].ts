import NextAuth from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";

export default NextAuth({
  providers: [
    KeycloakProvider({
      clientId: process.env.KEYCLOAK_CLIENT_ID || "",
      clientSecret: process.env.KEYCLOAK_CLIENT_SECRET || "",
      issuer: process.env.KEYCLOAK_ISSUER || "",
    }),
  ],
  secret: process.env.NEXTAUTH_SECRET,
  callbacks: {
    async redirect({ url, baseUrl }) {
      // Ensure redirects include the /libertyX base path
      if (url.startsWith("/")) return `${process.env.NEXTAUTH_URL}${url}`;
      else if (new URL(url).origin === baseUrl) return url;
      return process.env.NEXTAUTH_URL || baseUrl;
    },
  },
}); 