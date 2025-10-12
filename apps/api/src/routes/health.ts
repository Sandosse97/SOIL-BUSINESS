import { FastifyPluginAsync } from 'fastify'

const health: FastifyPluginAsync = async (server) => {
  server.get('/health', async () => ({ status: 'ok', time: new Date().toISOString() }))
}

export default health
