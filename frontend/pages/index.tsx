import { signIn, signOut, useSession } from "next-auth/react";
import React, { useEffect, useState } from "react";

interface Emp {
  id: number;
  firstName: string;
  lastName: string;
  birthDate?: string;
  salary?: string;
}

const Home: React.FC = () => {
  const { data: session } = useSession();
  const [emps, setEmps] = useState<Emp[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Add form state
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [birthDate, setBirthDate] = useState("");
  const [salary, setSalary] = useState("");
  const [formError, setFormError] = useState("");

  const fetchEmps = () => {
    setLoading(true);
    fetch("/emp")
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
    fetchEmps();
  }, []);

  // Form submission handler
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError("");
    if (!firstName || !lastName) {
      setFormError("First name and last name are required.");
      return;
    }
    const payload = {
      firstName,
      lastName,
      birthDate: birthDate || undefined,
      salary: salary || undefined,
    };
    try {
      const res = await fetch("/emp", {
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
      <h2 style={{ marginTop: "2rem" }}>Employees</h2>
      {loading && <p>Loading...</p>}
      {error && <p style={{ color: "red" }}>{error}</p>}
      <form onSubmit={handleSubmit} style={{ margin: "2rem auto", maxWidth: 400, padding: 20, border: "1px solid #ccc", borderRadius: 8 }}>
        <h3>Add Employee</h3>
        <div style={{ marginBottom: 12 }}>
          <input placeholder="First Name" value={firstName} onChange={e => setFirstName(e.target.value)} style={{ width: "48%", marginRight: 12, padding: 6 }} />
          <input placeholder="Last Name" value={lastName} onChange={e => setLastName(e.target.value)} style={{ width: "48%", padding: 6 }} />
        </div>
        <div style={{ marginBottom: 12 }}>
          <input type="date" placeholder="Birth Date" value={birthDate} onChange={e => setBirthDate(e.target.value)} style={{ width: "48%", marginRight: 12, padding: 6 }} />
          <input placeholder="Salary" value={salary} onChange={e => setSalary(e.target.value)} style={{ width: "48%", padding: 6 }} />
        </div>
        {formError && <div style={{ color: "red", marginBottom: 12 }}>{formError}</div>}
        <button type="submit" style={{ width: "100%", padding: 8 }}>Add Employee</button>
      </form>
      {emps.length > 0 && (
        <table style={{ margin: "2rem auto", minWidth: 500, borderCollapse: "collapse" }}>
          <thead>
            <tr>
              <th style={{ border: "1px solid #ccc", padding: 8 }}>First Name</th>
              <th style={{ border: "1px solid #ccc", padding: 8 }}>Last Name</th>
              <th style={{ border: "1px solid #ccc", padding: 8 }}>Birth Date</th>
              <th style={{ border: "1px solid #ccc", padding: 8 }}>Salary</th>
            </tr>
          </thead>
          <tbody>
            {emps.map((e) => (
              <tr key={e.id}>
                <td style={{ border: "1px solid #ccc", padding: 8 }}>{e.firstName}</td>
                <td style={{ border: "1px solid #ccc", padding: 8 }}>{e.lastName}</td>
                <td style={{ border: "1px solid #ccc", padding: 8 }}>{e.birthDate || "-"}</td>
                <td style={{ border: "1px solid #ccc", padding: 8 }}>{e.salary || "-"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default Home; 