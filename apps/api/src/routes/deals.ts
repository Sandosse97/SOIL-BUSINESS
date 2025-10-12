import { FastifyPluginAsync } from 'fastify'
import { z } from 'zod'
import prisma from '../lib/prisma'

// Dev auth placeholder (attach a fake user)
const auth = async (request: any, reply: any) => {
  request.user = { id: 'dev-user-1', email: 'dev@example.com', role: 'ADMIN' }
}

const deals: FastifyPluginAsync = async (server) => {
  server.get('/deals/auctions', async (request, reply) => {
    const auctions = await prisma.auction.findMany({ include: { bids: true } })
    return { auctions }
  })

  server.get('/deals/auctions/:id', async (request, reply) => {
    const { id } = request.params as any
    const auction = await prisma.auction.findUnique({ where: { id }, include: { bids: true } })
    if (!auction) return reply.status(404).send({ error: 'not found' })
    return { auction }
  })

  // Wallet endpoints (dev)
  server.get('/deals/me/wallet', { preHandler: [auth as any] }, async (req: any) => {
    const w = await prisma.wallet.upsert({ where: { userId: req.user.id }, update: {}, create: { userId: req.user.id } })
    return { ok: true, data: w }
  })

  server.post('/deals/me/wallet/topup', { preHandler: [auth as any] }, async (req: any) => {
    const schema = z.object({ amount: z.number().positive() })
    const { amount } = schema.parse(req.body)
    await prisma.$transaction([
      prisma.wallet.upsert({ where: { userId: req.user.id }, update: { balance: { increment: amount } }, create: { userId: req.user.id, balance: amount } }),
      prisma.transaction.create({ data: { userId: req.user.id, type: 'CREDIT' as any, amount: amount as any, note: 'dev-topup' } })
    ])
    return { ok: true }
  })

  // Place bid
  server.post('/deals/auctions/:id/bid', { preHandler: [auth as any] }, async (req: any, reply) => {
    const { id } = req.params as any
    const { amount } = z.object({ amount: z.number().positive() }).parse(req.body)
    const auction = await prisma.auction.findUnique({ where: { id }, include: { bids: true } })
    if (!auction || auction.status !== 'LIVE') return reply.code(400).send({ ok: false, error: 'Auction not live' })

    const now = new Date()
    const cutoff = new Date((auction as any).extendedUntil ?? (auction as any).endsAt)
    if (now > cutoff) return reply.code(400).send({ ok: false, error: 'Auction ended' })

    const minNext = Number((auction as any).currentPrice) + Number((auction as any).minIncrement)
    if (amount < minNext) return reply.code(400).send({ ok: false, error: `Min bid is ${minNext}` })

    const wallet = await prisma.wallet.upsert({ where: { userId: req.user.id }, update: {}, create: { userId: req.user.id } })
    if (Number(wallet.balance) < 0) return reply.code(400).send({ ok: false, error: 'Insufficient balance' })

    const res = await prisma.$transaction(async (tx) => {
      const b = await tx.bid.create({ data: { auctionId: id, bidderId: req.user.id, amount } })
      const soft = (auction as any).softCloseSec ?? 30
      const secondsLeft = ((cutoff.getTime() - now.getTime()) / 1000) | 0
      const extend = secondsLeft <= soft
      const extendedUntil = extend ? new Date(now.getTime() + soft * 1000) : (auction as any).extendedUntil
      const a = await tx.auction.update({ where: { id }, data: { currentPrice: amount as any, extendedUntil } } as any)
      return { b, a }
    })

    server.io?.of('/deals')?.to(id).emit('bid_placed', { auctionId: id, amount, bidderId: req.user.id })
    return { ok: true, data: res }
  })

  // Buy now
  server.post('/deals/auctions/:id/buy-now', { preHandler: [auth as any] }, async (req: any, reply) => {
    const { id } = req.params as any
    const a = await prisma.auction.findUnique({ where: { id } })
    if (!(a as any)?.buyNowPrice || a?.status !== 'LIVE') return reply.code(400).send({ ok: false, error: 'Not available' })
    await prisma.auction.update({ where: { id }, data: { status: 'ENDED' as any, winnerId: req.user.id } } as any)
    server.io?.of('/deals')?.emit('auction_updated', { id })
    return { ok: true }
  })
}

export type DealsSocketEvents = {
  bid_placed: { auctionId: string; amount: number; bidderId: string }
  auction_updated: { id: string }
}

export default deals
