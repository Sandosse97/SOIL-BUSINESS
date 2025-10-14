// Temporary auth middleware - replace with proper JWT validation later
export const auth = async (request: any, reply: any) => {
  // For development, just pass through
  // In production, validate JWT token here
  const token = request.headers.authorization?.replace('Bearer ', '')
  
  if (!token) {
    return reply.code(401).send({ ok: false, error: 'Authorization required' })
  }
  
  // Mock user for development
  request.user = { id: 'dev-user-123', email: 'dev@example.com' }
  return
}