'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function SignIn() {
  const [email, setEmail] = useState('dev@example.com')
  const router = useRouter()
  return (
    <main>
      <h1>Dev sign in</h1>
      <p>This is a dev-only signin. It stores a fake JWT in localStorage.</p>
      <form onSubmit={(e) => { e.preventDefault(); localStorage.setItem('jwt', 'dev-jwt-token'); router.push('/') }}>
        <input value={email} onChange={(e) => setEmail(e.target.value)} />
        <button type="submit">Sign in (dev)</button>
      </form>
    </main>
  )
}
