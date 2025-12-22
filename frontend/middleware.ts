import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
    // Get the session token from cookies
    const sessionToken = request.cookies.get('__Secure-next-auth.session-token');
    const callbackSessionToken = request.cookies.get('next-auth.session-token');

    // Check if user is authenticated
    const isAuthenticated = sessionToken || callbackSessionToken;

    // Get the pathname
    const { pathname } = request.nextUrl;

    // Allow NextAuth API routes and auth pages
    if (pathname.startsWith('/libertyX/api/auth')) {
        return NextResponse.next();
    }

    // If not authenticated and trying to access a protected page, redirect to sign-in
    if (!isAuthenticated && pathname !== '/libertyX/api/auth/signin') {
        const signInUrl = new URL('/libertyX/api/auth/signin', request.url);
        signInUrl.searchParams.set('callbackUrl', request.url);
        return NextResponse.redirect(signInUrl);
    }

    return NextResponse.next();
}

export const config = {
    matcher: [
        /*
         * Match all paths except:
         * - _next/static (static files)
         * - _next/image (image optimization files)
         * - favicon.ico (favicon file)
         */
        '/((?!_next/static|_next/image|favicon.ico).*)',
    ],
};
