'use client';
import useSWR from 'swr';
import Link from 'next/link';
const fetcher = (u: string) => fetch(u).then(r => r.json());
export default function DealsIndex() {
  const { data } = useSWR('http://localhost:4000/deals/auctions', fetcher, { refreshInterval: 1500 });
  return (
    <main>
      <h1>Live Deals</h1>
      <p>Browse live auctions. Sign in to bid.</p>
      <ul>
        {(data?.data ?? []).map((a: any) => (
          <li key={a.id} style={{ marginBottom: 12 }}>
            <Link href={`/deals/${a.id}`}>{a.title}</Link> — ends {new Date(a.extendedUntil ?? a.endsAt).toLocaleString()} — current €{a.currentPrice}
          </li>
        ))}
      </ul>
    </main>
  );
}
