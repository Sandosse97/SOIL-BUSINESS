import React from 'react'

export default function Deal({ auction }: { auction: any }) {
  if (!auction) return <div>Not found</div>
  return (
    <div>
      <h1>{auction.title}</h1>
      <p>{auction.description}</p>
      <p>Status: {auction.status}</p>
      <form onSubmit={async (e) => {
        e.preventDefault()
        const amount = Number((e.currentTarget as any).amount.value)
        const token = typeof window !== 'undefined' ? localStorage.getItem('jwt') : null
        const headers: any = { 'Content-Type': 'application/json' }
        if (token) headers['Authorization'] = `Bearer ${token}`
        const res = await fetch(`${process.env.API_URL || 'http://localhost:4000'}/deals/auctions/${auction.id}/bid`, { method: 'POST', headers, body: JSON.stringify({ amount }) })
        const j = await res.json()
        console.log(j)
        if (j.ok) alert('Bid placed')
      }}>
        <input name="amount" type="number" step="0.01" />
        <button type="submit">Place bid</button>
      </form>
    </div>
  )
}

export async function getServerSideProps(ctx: any) {
  const { id } = ctx.params
  const API = process.env.API_URL || 'http://localhost:4000'
  try {
    const res = await fetch(`${API}/deals/auctions/${id}`)
    const data = await res.json()
    return { props: { auction: data.auction ?? null } }
  } catch (err) {
    return { props: { auction: null } }
  }
}