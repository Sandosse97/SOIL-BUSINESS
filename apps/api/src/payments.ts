import { FastifyInstance } from 'fastify'
import Stripe from 'stripe'
import { PrismaClient, TxnType } from '@prisma/client'

const prisma = new PrismaClient()
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY as string, { apiVersion: '2024-06-20' })

const ENV = {
  // In production set WEB_URL=https://your-frontend.example.com
  WEB_URL: process.env.WEB_URL ?? 'https://your-frontend.example.com'
}

export async function paymentsPlugin(app: FastifyInstance) {
  // Dev auth placeholder (same as in deals.ts)
  const auth = async (request: any, reply: any) => {
    request.user = { id: 'dev-user-1', email: 'dev@example.com', role: 'ADMIN' }
  }

  // Create a Checkout Session for wallet topup
  app.post('/payments/checkout', { preHandler: [auth] }, async (req: any, reply) => {
    const { amount } = (req.body as any) as { amount: number } // amount in EUR, e.g. 20.00
    if (!amount || amount <= 0) return reply.code(400).send({ ok: false, error: 'Invalid amount' })

    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      payment_method_types: ['card'],
      success_url: `${ENV.WEB_URL}/deals?topup=success`,
      cancel_url: `${ENV.WEB_URL}/deals?topup=cancel`,
      currency: 'eur',
      line_items: [
        {
          price_data: {
            currency: 'eur',
            product_data: { name: 'Wallet top-up' },
            unit_amount: Math.round(amount * 100)
          },
          quantity: 1
        }
      ],
      metadata: { userId: req.user?.id, kind: 'wallet_topup' }
    })
    return { ok: true, data: { url: session.url } }
  })

  // Webhook: credit wallet on successful payment
  app.post('/payments/webhook', { config: { rawBody: true } } as any, async (req: any, reply) => {
    const sig = req.headers['stripe-signature'] as string
    let event: Stripe.Event
    try {
      // fastify-raw-body will populate request.rawBody when enabled for the route
      const payload = (req as any).rawBody ?? (req as any).body
      event = stripe.webhooks.constructEvent(payload, sig, process.env.STRIPE_WEBHOOK_SECRET as string)
    } catch (err: any) {
      app.log.error({ err }, 'Webhook signature verification failed')
      return reply.code(400).send(`Webhook Error: ${err.message}`)
    }

    if (event.type === 'checkout.session.completed') {
      const session = event.data.object as Stripe.Checkout.Session
      if (session.metadata?.kind === 'wallet_topup' && session.amount_total && session.metadata.userId) {
        const amount = Number(session.amount_total) / 100
        const userId = session.metadata.userId
        await prisma.$transaction([
          prisma.wallet.upsert({ where: { userId }, update: { balance: { increment: amount } }, create: { userId, balance: amount } }),
          prisma.transaction.create({ data: { userId, type: TxnType.CREDIT, amount, ref: session.id as string, note: 'stripe-topup' } })
        ])
      }
    }

    return reply.send({ received: true })
  })

  // Admin/dev: refund a top-up by ref (Checkout Session id)
  app.post('/payments/refund', { preHandler: [auth] }, async (req: any, reply) => {
    if (req.user.role !== 'ADMIN') return reply.code(403).send({ ok: false, error: 'Forbidden' })
    const { ref, amount } = (req.body as any) as { ref: string; amount?: number }
    if (!ref) return reply.code(400).send({ ok: false, error: 'Missing ref' })

    // Find the PaymentIntent from the Checkout Session
    const session = await stripe.checkout.sessions.retrieve(ref as string)
    if (!session.payment_intent) return reply.code(400).send({ ok: false, error: 'No payment intent' })
    const piId = typeof session.payment_intent === 'string' ? session.payment_intent : session.payment_intent.id

    // Issue refund
    const refund = await stripe.refunds.create({ payment_intent: piId, amount: amount ? Math.round(amount * 100) : undefined })

    // (Optional) decrement wallet balance off-ledger; admin should ensure sufficient balance
    return { ok: true, data: { refundId: refund.id } }
  })
}

export default paymentsPlugin
