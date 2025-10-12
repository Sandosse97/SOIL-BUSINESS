'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function DealPage({ params }: { params: { id: string } }) {
  const [auction, setAuction] = useState<any>(null)
  const router = useRouter()
  const API = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000'

  // Fetch on client mount
  if (!auction) {
    fetch(`${API}/deals/auctions/${params.id}`).then(r => r.json()).then(j => setAuction(j.auction))
  }

  if (!auction) return <div>Loading...</div>

  return (
    <main>
      <h1>{auction.title}</h1>
      <p>{auction.description}</p>
      <p>Ends: {new Date(auction.extendedUntil ?? auction.endsAt).toLocaleString()}</p>
      <p>Current: €{auction.currentPrice}</p>

      <form onSubmit={async (e) => {
        e.preventDefault()
        const amount = Number((e.currentTarget as any).amount.value)
        const token = localStorage.getItem('jwt')
        const headers: any = { 'Content-Type': 'application/json' }
        if (token) headers['Authorization'] = `Bearer ${token}`
        const res = await fetch(`${API}/deals/auctions/${params.id}/bid`, { method: 'POST', headers, body: JSON.stringify({ amount }) })
        const j = await res.json()
        if (j.ok) {
          alert('Bid placed')
          router.refresh()
          import { useEffect, useState } from 'react';
          import { useRouter } from 'next/navigation';


          export default function DealDetail({ params }: { params: { id: string } }) {
            const id = params.id;
            const [auction, setAuction] = useState<any>(null);
            const [amount, setAmount] = useState('');
            const router = useRouter();


            async function load() {
              const API = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000'
              const res = await fetch(`${API}/deals/auctions/${id}`);
              const j = await res.json();
              setAuction(j.data ?? j.auction ?? j)
            }


            useEffect(() => { load(); const t = setInterval(load, 1500); return () => clearInterval(t); }, [id]);


            async function bid() {
            const token = localStorage.getItem('jwt');
              if (!token) { alert('Please sign in first'); return; }
              const res = await fetch(`http://localhost:4000/deals/auctions/${id}/bid`, { method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` }, body: JSON.stringify({ amount: Number(amount) }) });
              const j = await res.json();
              if (!j.ok) alert(j.error || 'Bid failed'); else setAmount('');
            }


            async function topup() {
              const token = localStorage.getItem('mlv_jwt');
              if (!token) { alert('Please sign in first'); return; }
              const amt = Number(prompt('Top up amount in EUR', '20'));
              if (!amt || amt <= 0) return;
            const API = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000'
            const res = await fetch(`${API}/payments/checkout`, { method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` }, body: JSON.stringify({ amount: amt }) });
              const j = await res.json();
              if (j.ok && j.data?.url) window.location.href = j.data.url; else alert('Checkout failed');
            }


            if (!auction) return <p>Loading…</p>;
            return (
              <main>
                <h1>{auction.title}</h1>
                <p>{auction.description}</p>
                <p>Ends: {new Date(auction.extendedUntil ?? auction.endsAt).toLocaleString()}</p>
                <p>Current price: €{auction.currentPrice} — Min increment: €{auction.minIncrement}</p>
                <div style={{ display: 'flex', gap: 8 }}>
                  <input value={amount} onChange={e => setAmount(e.target.value)} placeholder="Your bid (€)" />
                  <button onClick={bid}>Place Bid</button>
                  <button onClick={topup}>Top up</button>
                </div>
              </main>
            );
          }
