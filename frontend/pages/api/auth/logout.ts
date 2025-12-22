import { NextApiRequest, NextApiResponse } from 'next';
import { getServerSession } from 'next-auth/next';
import { getToken } from 'next-auth/jwt';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
    try {
        // Get the token which contains the id_token
        const token = await getToken({ req, secret: process.env.NEXTAUTH_SECRET });

        // Build Keycloak logout URL
        const keycloakIssuer = process.env.KEYCLOAK_ISSUER || 'https://olite.hd.free.fr/libertyX/auth/realms/myapp';
        const logoutUrl = `${keycloakIssuer}/protocol/openid-connect/logout`;

        const params = new URLSearchParams({
            post_logout_redirect_uri: 'https://olite.hd.free.fr/libertyX/',
        });

        // Add id_token_hint if available
        if (token?.id_token) {
            params.append('id_token_hint', token.id_token as string);
        }

        // Redirect to Keycloak logout
        res.redirect(`${logoutUrl}?${params.toString()}`);
    } catch (error) {
        console.error('Logout error:', error);
        res.redirect('/libertyX/');
    }
}
