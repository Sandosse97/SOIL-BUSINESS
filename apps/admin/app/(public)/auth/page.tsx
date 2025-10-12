'use client';
import React from 'react';
import { useState } from 'react';


export default function AuthPage() {
  const [email, setEmail] = useState('');
  const [code, setCode] = useState('');
  const [sent, setSent] = useState(false);


  async function request() {
    await fetch('http://localhost:4000/auth/request-otp', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email }) });
    setSent(true);
  }
  async function verify() {
    const res = await fetch('http://localhost:4000/auth/verify', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email, code }) });
    const j = await res.json();
    if (j.ok) { localStorage.setItem('mlv_jwt', j.data.token); window.location.href = '/deals'; }
  }


  return (
    <main>
      <h1>Sign in</h1>
      <input placeholder="email" value={email} onChange={e => setEmail(e.target.value)} />
      {!sent ? <button onClick={request}>Request Code</button> : (
        <>
          <input placeholder="6-digit code" value={code} onChange={e => setCode(e.target.value)} />
          <button onClick={verify}>Verify</button>
        </>
      )}
    </main>
  );
}
