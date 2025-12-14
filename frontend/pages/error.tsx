import { useRouter } from 'next/router';
import React from 'react';

const ErrorPage: React.FC = () => {
  const router = useRouter();
  const { error } = router.query;

  const errors: { [key: string]: string } = {
    Configuration: 'There is a problem with the server configuration.',
    AccessDenied: 'You do not have permission to sign in.',
    Verification: 'The verification token has expired or has already been used.',
    OAuthSignin: 'Error occurred during OAuth sign-in. Please check your Keycloak configuration.',
    OAuthCallback: 'Error occurred during OAuth callback.',
    OAuthCreateAccount: 'Could not create OAuth provider user in the database.',
    EmailCreateAccount: 'Could not create email provider user in the database.',
    Callback: 'Error in the OAuth callback handler route.',
    OAuthAccountNotLinked: 'The email address is already linked to another account.',
    EmailSignin: 'Sending the e-mail with the verification token failed.',
    CredentialsSignin: 'Sign in with credentials failed. Check that the details you provided are correct.',
    SessionRequired: 'Please sign in to access this page.',
    Default: 'An unexpected error occurred.',
  };

  const errorMessage = error && typeof error === 'string' ? errors[error] : errors.Default;

  return (
    <div style={{ display: 'flex', minHeight: '100vh', fontFamily: 'system-ui, -apple-system, Segoe UI, Roboto, sans-serif', alignItems: 'center', justifyContent: 'center', background: '#f3f4f6' }}>
      <div style={{ maxWidth: 500, padding: 32, background: '#fff', borderRadius: 8, boxShadow: '0 4px 6px rgba(0,0,0,0.1)' }}>
        <h1 style={{ color: '#dc2626', marginTop: 0 }}>Authentication Error</h1>
        <p style={{ fontSize: 16, color: '#374151', marginBottom: 24 }}>{errorMessage}</p>
        {error && (
          <div style={{ padding: 12, background: '#fee', borderRadius: 6, marginBottom: 24 }}>
            <p style={{ margin: 0, fontSize: 14, color: '#991b1b' }}>Error Code: <strong>{error}</strong></p>
          </div>
        )}
        <div style={{ display: 'flex', gap: 12 }}>
          <button 
            onClick={() => router.push('/libertyX')} 
            style={{ flex: 1, padding: '10px 16px', background: '#3b82f6', color: '#fff', border: 'none', borderRadius: 6, cursor: 'pointer', fontSize: 16 }}
          >
            Return Home
          </button>
          <button 
            onClick={() => router.push('/libertyX/api/auth/signin')} 
            style={{ flex: 1, padding: '10px 16px', background: '#10b981', color: '#fff', border: 'none', borderRadius: 6, cursor: 'pointer', fontSize: 16 }}
          >
            Try Again
          </button>
        </div>
      </div>
    </div>
  );
};

export default ErrorPage;
