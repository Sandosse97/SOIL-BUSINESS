import { describe, it, expect } from 'vitest'
import { generateOtp, verifyOtp } from '../lib/otp'

describe('otp helper', () => {
  it('generates and verifies the dev otp', () => {
    const otp = generateOtp()
    expect(otp).toBe('123456')
    expect(verifyOtp('123456')).toBe(true)
    expect(verifyOtp('000000')).toBe(false)
  })
})
