export { default } from 'next-auth/middleware';

export const config = {
    matcher: [
        /*
         * Match all pages except auth pages and static files
         */
        '/libertyX/((?!api/auth|_next/static|_next/image|favicon.ico).*)',
    ],
};
