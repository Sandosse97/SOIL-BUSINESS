'use client';
import Link from 'next/link';

export default function Home() {
  return (
    <main style={{ padding: 24 }}>
      <h1>Meetloview Admin</h1>
      <ul>
        <li><Link href="/auth">Sign in (public)</Link></li>
        <li><Link href="/deals">Deals (public)</Link></li>
      </ul>
    </main>
  );
}
