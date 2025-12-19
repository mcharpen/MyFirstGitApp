import { getProviders, signIn, LiteralUnion, ClientSafeProvider } from "next-auth/react";
import { GetServerSidePropsContext } from "next";
import { BuiltInProviderType } from "next-auth/providers";

interface SignInProps {
  providers: Record<LiteralUnion<BuiltInProviderType, string>, ClientSafeProvider>;
}

export default function SignIn({ providers }: SignInProps) {
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

export async function getServerSideProps(context: GetServerSidePropsContext) {
  const providers = await getProviders();
  return {
    props: { providers },
  };
}
