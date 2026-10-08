import { describe, expect, it } from 'vitest'
import { displayPhone, formatPhoneEdit, tmPhone } from './phone'

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

describe('formatPhoneEdit', () => {
  const typeAll = (keys: string) => {
    let v = { text: '', cursor: 0 }
    for (const k of keys) v = formatPhoneEdit(v.text, v.text.slice(0, v.cursor) + k + v.text.slice(v.cursor), v.cursor + 1)
    return v.text
  }

  it('shows +993 XX XXXXXX while typing and stops after 8 digits', () => {
    expect(typeAll('6')).toBe('+993 6')
    expect(typeAll('651')).toBe('+993 65 1')
    expect(typeAll('651234567')).toBe('+993 65 123456')
    expect(typeAll('865123456')).toBe('+993 65 123456')
    expect(formatPhoneEdit('', '+993 65 12 34 56', 16).text).toBe('+993 65 123456')
    expect(tmPhone(typeAll('65123456'), 'mobile')).toBe('+99365123456')
  })

  it('backspace steps over spaces and the prefix', () => {
    expect(formatPhoneEdit('+993 65 1', '+993 651', 7).text).toBe('+993 61')
    expect(formatPhoneEdit('+993 6', '+993 ', 5).text).toBe('')
    expect(formatPhoneEdit('+993 65 1', '+93 65 1', 2).text).toBe('+993 65 1')
  })

  it('shows stored numbers formatted', () => {
    expect(displayPhone('+99362112233')).toBe('+993 62 112233')
    expect(displayPhone(null)).toBe('')
  })
})
