import { signIn, signOut, useSession } from "next-auth/react";

const Home: React.FC = () => {
  const { data: session } = useSession();

  return (
    <div style={{ textAlign: 'center', marginTop: '2rem' }}>
      <h1>Welcome to MyFirstGitApp Frontend (Next.js + TypeScript)</h1>
      {session ? (
        <>
          <p>Signed in as {session.user?.email || session.user?.name}</p>
          <button onClick={() => signOut()}>Sign out</button>
        </>
      ) : (
        <button onClick={() => signIn("keycloak")}>Login with Keycloak</button>
      )}
    </div>
  );
};

export default Home; 