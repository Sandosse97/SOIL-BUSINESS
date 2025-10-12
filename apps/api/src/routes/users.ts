import { FastifyPluginAsync } from 'fastify'

const users: FastifyPluginAsync = async (server) => {
  server.get('/users', async () => {
    return { users: [] }
  })
}

export default users
