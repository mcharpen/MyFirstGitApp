import React, { useEffect, useState } from "react";
import { signIn, signOut, useSession } from "next-auth/react";

interface Emp {
    id: number;
    firstName: string;
    lastName: string;
    birthDate?: string;
    salary?: string;
}

const Home: React.FC = () => {
    const { data: session } = useSession ? useSession() : { data: undefined } as any;
    const [emps, setEmps] = useState<Emp[]>([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    // Form state (if backend is present)
    const [firstName, setFirstName] = useState("");
    const [lastName, setLastName] = useState("");
    const [birthDate, setBirthDate] = useState("");
    const [salary, setSalary] = useState("");
    const [formError, setFormError] = useState("");

    const fetchEmps = () => {
        setLoading(true);
        fetch("/libertyX/emp")
            .then((r) => {
                if (!r.ok) throw new Error("Failed to fetch emps");
                return r.json();
            })
            .then((data) => {
                setEmps(data);
                setLoading(false);
            })
            .catch((e) => {
                setError(e.message);
                setLoading(false);
            });
    };

    useEffect(() => {
        // Attempt to fetch employees if backend route is available
        fetchEmps();
    }, []);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setFormError("");
        if (!firstName || !lastName) {
            setFormError("First name and last name are required.");
            return;
        }
        const payload = { firstName, lastName, birthDate: birthDate || undefined, salary: salary || undefined };
        try {
            const res = await fetch("/libertyX/emp", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload),
            });
            if (!res.ok) throw new Error(await res.text());
            setFirstName(""); setLastName(""); setBirthDate(""); setSalary("");
            fetchEmps();
        } catch (err: any) {
            setFormError(typeof err === "string" ? err : err.message || "Unknown error");
        }
    };

    return (
        <div style={{ display: 'flex', minHeight: '100vh', fontFamily: 'system-ui, -apple-system, Segoe UI, Roboto, sans-serif' }}>
            {/* Sidebar */}
            <aside style={{ width: 220, background: '#111827', color: '#fff', padding: '16px 12px' }}>
                <div style={{ fontSize: 18, fontWeight: 700, marginBottom: 16 }}>Menu</div>
                <nav>
                    <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
                        <li style={{ padding: '8px 6px', borderRadius: 6, cursor: 'pointer', background: '#1f2937', marginBottom: 8 }}>
                            <a href="/employees" style={{ color: '#fff', textDecoration: 'none', display: 'block' }}>Employees</a>
                        </li>
                        <li style={{ padding: '8px 6px', borderRadius: 6, cursor: 'pointer', background: '#1f2937', marginBottom: 8 }}>
                            <a href="/jobs" style={{ color: '#fff', textDecoration: 'none', display: 'block' }}>Jobs</a>
                        </li>
                        <li style={{ padding: '8px 6px', borderRadius: 6, cursor: 'pointer', background: '#1f2937' }}>
                            <a href="/location" style={{ color: '#fff', textDecoration: 'none', display: 'block' }}>Location</a>
                        </li>
                    </ul>
                </nav>
            </aside>

            {/* Main content */}
            <main style={{ flex: 1, padding: '24px' }}>
                <h1 style={{ marginTop: 0 }}>Welcome to Libertinage</h1>
                <div style={{ marginBottom: 16 }}>
                    {session ? (
                        <>
                            <span>Signed in as {session.user?.email || session.user?.name}</span>
                            <button onClick={() => signOut ? signOut({ callbackUrl: '/libertyX/' }) : undefined} style={{ marginLeft: 12 }}>Sign out</button>
                        </>
                    ) : (
                        <button onClick={() => signIn ? signIn("keycloak") : undefined}>Login with Keycloak</button>
                    )}
                </div>

                <section>
                    <h2>Employees</h2>
                    {loading && <p>Loading...</p>}
                    {error && <p style={{ color: 'red' }}>{error}</p>}

                    <form onSubmit={handleSubmit} style={{ margin: '1rem 0', maxWidth: 520, padding: 16, border: '1px solid #e5e7eb', borderRadius: 8 }}>
                        <h3 style={{ marginTop: 0 }}>Add Employee</h3>
                        <div style={{ display: 'flex', gap: 12, marginBottom: 12 }}>
                            <input placeholder="First Name" value={firstName} onChange={e => setFirstName(e.target.value)} style={{ flex: 1, padding: 8, border: '1px solid #d1d5db', borderRadius: 6 }} />
                            <input placeholder="Last Name" value={lastName} onChange={e => setLastName(e.target.value)} style={{ flex: 1, padding: 8, border: '1px solid #d1d5db', borderRadius: 6 }} />
                        </div>
                        <div style={{ display: 'flex', gap: 12, marginBottom: 12 }}>
                            <input type="date" value={birthDate} onChange={e => setBirthDate(e.target.value)} style={{ flex: 1, padding: 8, border: '1px solid #d1d5db', borderRadius: 6 }} />
                            <input placeholder="Salary" value={salary} onChange={e => setSalary(e.target.value)} style={{ flex: 1, padding: 8, border: '1px solid #d1d5db', borderRadius: 6 }} />
                        </div>
                        {formError && <div style={{ color: 'red', marginBottom: 8 }}>{formError}</div>}
                        <button type="submit" style={{ padding: '8px 12px' }}>Add Employee</button>
                    </form>

                    {emps.length > 0 && (
                        <table style={{ width: '100%', maxWidth: 800, borderCollapse: 'collapse' }}>
                            <thead>
                                <tr>
                                    <th style={{ border: '1px solid #e5e7eb', padding: 8, textAlign: 'left' }}>First Name</th>
                                    <th style={{ border: '1px solid #e5e7eb', padding: 8, textAlign: 'left' }}>Last Name</th>
                                    <th style={{ border: '1px solid #e5e7eb', padding: 8, textAlign: 'left' }}>Birth Date</th>
                                    <th style={{ border: '1px solid #e5e7eb', padding: 8, textAlign: 'left' }}>Salary</th>
                                </tr>
                            </thead>
                            <tbody>
                                {emps.map((e) => (
                                    <tr key={e.id}>
                                        <td style={{ border: '1px solid #e5e7eb', padding: 8 }}>{e.firstName}</td>
                                        <td style={{ border: '1px solid #e5e7eb', padding: 8 }}>{e.lastName}</td>
                                        <td style={{ border: '1px solid #e5e7eb', padding: 8 }}>{e.birthDate || '-'}</td>
                                        <td style={{ border: '1px solid #e5e7eb', padding: 8 }}>{e.salary || '-'}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </section>
            </main>
        </div>
    );
};

export default Home;
