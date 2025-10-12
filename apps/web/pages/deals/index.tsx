import React from 'react'

type Auction = any

export default function Deals({ auctions }: { auctions: Auction[] }) {
  return (
    <div>
      <h1>Auctions</h1>
      <ul>
        {auctions.map((a: any) => (
          <li key={a.id}><a href={`/deals/${a.id}`}>{a.title} - {a.status}</a></li>
        ))}
      </ul>
    </div>
  )
}

export async function getServerSideProps() {
  const API = process.env.API_URL || 'http://localhost:4000'
  try {
    const res = await fetch(`${API}/deals/auctions`)
    const data = await res.json()
    return { props: { auctions: data.auctions ?? [] } }
  } catch (err) {
    return { props: { auctions: [] } }
  }
}