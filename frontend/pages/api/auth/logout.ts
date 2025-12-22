import { NextApiRequest, NextApiResponse } from 'next';
import { getToken } from 'next-auth/jwt';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
    try {
        // Get the token which contains the id_token BEFORE destroying the session
        const token = await getToken({ req, secret: process.env.NEXTAUTH_SECRET });

        console.log('[Logout] Token retrieved:', token ? 'yes' : 'no');
        console.log('[Logout] ID Token present:', token?.id_token ? 'yes' : 'no');

        // Build Keycloak logout URL
        const keycloakIssuer = process.env.KEYCLOAK_ISSUER || 'https://olite.hd.free.fr/libertyX/auth/realms/myapp';
        const logoutUrl = `${keycloakIssuer}/protocol/openid-connect/logout`;

        const params = new URLSearchParams({
            post_logout_redirect_uri: 'https://olite.hd.free.fr/libertyX/api/auth/signout',
        });

        // Add id_token_hint if available
        if (token?.id_token) {
            params.append('id_token_hint', token.id_token as string);
            console.log('[Logout] Adding id_token_hint to logout URL');
        } else {
            console.log('[Logout] WARNING: No id_token found in session');
        }

        const finalUrl = `${logoutUrl}?${params.toString()}`;
        console.log('[Logout] Redirecting to:', finalUrl);

        // Redirect to Keycloak logout (which will then redirect back to our signout page)
        res.redirect(finalUrl);
    } catch (error) {
        console.error('[Logout] Error during logout:', error);
        res.redirect('/libertyX/api/auth/signout');
    }
}
