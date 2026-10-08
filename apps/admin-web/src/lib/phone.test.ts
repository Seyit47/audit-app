import { describe, expect, it } from 'vitest'
import { tmPhone } from './phone'

describe('tmPhone', () => {
  it('accepts the common ways of writing a Turkmen number', () => {
    for (const input of ['+993 65 12 34 56', '99365123456', '8 65 123456', '65123456', '+993 (12) 34-56-78']) {
      expect(tmPhone(input, 'any'), input).toMatch(/^\+993\d{8}$/)
    }
    expect(tmPhone('8 65 123456', 'any')).toBe('+99365123456')
  })

  it('salesmen need a mobile number; shops may give a landline', () => {
    expect(tmPhone('+993 12 345678', 'mobile')).toBeNull()
    expect(tmPhone('+993 12 345678', 'any')).toBe('+99312345678')
    expect(tmPhone('+993 71 123456', 'mobile')).toBe('+99371123456')
  })

  it('rejects other countries and wrong lengths', () => {
    for (const input of ['+7 912 345 67 89', '+993 65 12345', '+993 65 1234567', 'abc', '']) {
      expect(tmPhone(input, 'any'), input).toBeNull()
    }
  })
})
