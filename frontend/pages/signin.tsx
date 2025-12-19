import { getProviders, signIn } from "next-auth/react";

export default function SignIn({ providers }) {
  return (
    <div style={{ textAlign: 'center', marginTop: '2rem' }}>
      <h1>Sign in</h1>
      {providers && Object.values(providers).map((provider) => (
        <div key={provider.name} style={{ margin: '1rem' }}>
          <button onClick={() => signIn(provider.id)}>
            Sign in with {provider.name}
          </button>
        </div>
      ))}
    </div>
  );
}

export async function getServerSideProps(context) {
  const providers = await getProviders();
  return {
    props: { providers },
  };
}
