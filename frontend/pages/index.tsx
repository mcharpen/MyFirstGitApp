import React, { useState } from 'react';

const KEYCLOAK_BASE_URL = 'http://localhost:8089';
const REALM = 'app';
const CLIENT_ID = 'myapp-client';
const REDIRECT_URI = typeof window !== 'undefined' ? window.location.origin : '';

const Home: React.FC = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // Redirect to Keycloak login page with proper query params
    const keycloakLoginUrl = `${KEYCLOAK_BASE_URL}/realms/${REALM}/protocol/openid-connect/auth?client_id=${CLIENT_ID}&response_type=code&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
    window.location.href = keycloakLoginUrl;
  };

  return (
    <div style={{ textAlign: 'center', marginTop: '2rem' }}>
      <h1>Welcome to MyFirstGitApp Frontend (Next.js + TypeScript)</h1>
      <p>This is a minimal starter page.</p>
      <form onSubmit={handleLogin} style={{ margin: '2rem auto', maxWidth: 300 }}>
        <div style={{ marginBottom: '1rem' }}>
          <input
            type="text"
            placeholder="Username"
            value={username}
            onChange={e => setUsername(e.target.value)}
            style={{ width: '100%', padding: '0.5rem' }}
            autoComplete="username"
          />
        </div>
        <div style={{ marginBottom: '1rem' }}>
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={e => setPassword(e.target.value)}
            style={{ width: '100%', padding: '0.5rem' }}
            autoComplete="current-password"
          />
        </div>
        <button type="submit" style={{ width: '100%', padding: '0.5rem' }}>
          Login with Keycloak
        </button>
      </form>
    </div>
  );
};

export default Home; 