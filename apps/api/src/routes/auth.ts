import { FastifyPluginAsync } from 'fastify'
import { z } from 'zod'

const auth: FastifyPluginAsync = async (server) => {
  const reqOtpSchema = z.object({ email: z.string().email() })

  server.post('/auth/request-otp', async (request, reply) => {
    const body = reqOtpSchema.parse(request.body)
    // dev stub: return a static code
    server.log.info(`OTP requested for ${body.email}`)
    return { success: true, otpPreview: '123456' }
  })

  server.post('/auth/verify-otp', async (request, reply) => {
    const body = z.object({ email: z.string().email(), code: z.string() }).parse(request.body)
    server.log.info(`Verify OTP ${body.code} for ${body.email}`)
    // In prod issue JWT; dev stub returns a fake token
    return { success: true, token: 'dev-token-' + body.email }
  })
}

export default auth
