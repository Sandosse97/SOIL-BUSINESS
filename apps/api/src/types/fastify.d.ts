// Type augmentation pour Fastify avec Socket.IO
import { Server as SocketIOServer } from 'socket.io'

declare module 'fastify' {
  interface FastifyInstance {
    io?: SocketIOServer
  }
}