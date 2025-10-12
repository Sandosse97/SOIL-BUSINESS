import Fastify from 'fastify'
import cors from 'fastify-cors'
import helmet from 'fastify-helmet'
import rateLimit from 'fastify-rate-limit'
import fastifyRawBody from 'fastify-raw-body'
import dotenv from 'dotenv'
import fastifySocketIO from 'fastify-socket.io'
import paymentsPlugin from './payments'

dotenv.config()

const server = Fastify({ logger: true })

// keep permissive CORS in development; configure origin in production via env
void server.register(cors, { origin: process.env.CORS_ORIGIN || true })
void server.register(helmet)
void server.register(rateLimit, { max: 100, timeWindow: '1 minute' })

// register raw body parser before routes that need webhook raw body
void server.register(fastifyRawBody, {
  field: 'rawBody', // adds request.rawBody
  global: false, // enable only on routes that need it
  encoding: 'utf8',
  runFirst: true
})

void server.register(fastifySocketIO)

// Register routes
void server.register(import('./routes/health'))
void server.register(import('./routes/auth'))
void server.register(import('./routes/users'))
// register payments after auth so auth hooks are available
void server.register(paymentsPlugin as any)
void server.register(import('./routes/deals'))

server.ready().then(() => {
  const io = server.io
  io?.on('connection', (socket) => {
    server.log.info('socket connected: ' + socket.id)
    socket.on('join', (room) => socket.join(room))
    socket.on('message', (msg) => socket.to(msg.room).emit('message', msg))
  })
})

const start = async () => {
  try {
    const port = Number(process.env.PORT || 4000)
    await server.listen({ port, host: '0.0.0.0' })
    server.log.info(`Server listening on ${port}`)
  } catch (err) {
    server.log.error(err)
    process.exit(1)
  }
}

void start()
