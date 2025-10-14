'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'

export default function DealsIndex() {
  const [data, setData] = useState<any>(null)

  async function loadDeals() {
    try {
      const API = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000'
      const res = await fetch(`${API}/deals/auctions`)
      const json = await res.json()
      setData(json)
    } catch (error) {
      console.error('Failed to load deals:', error)
    }
  }

  useEffect(() => {
    loadDeals()
    const interval = setInterval(loadDeals, 1500)
    return () => clearInterval(interval)
  }, [])

  return (
    <main>
      <h1>Live Deals</h1>
      <p>Browse live auctions. Sign in to bid.</p>
      <ul>
        {(data?.data ?? []).map((a: any) => (
          <li key={a.id} style={{ marginBottom: 12 }}>
            <Link href={`/deals/${a.id}`}>
              {a.title}
            </Link> — ends {new Date(a.extendedUntil ?? a.endsAt).toLocaleString()} — current €{a.currentPrice}
          </li>
        ))}
      </ul>
    </main>
  )
}
