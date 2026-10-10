import { describe, expect, it } from 'vitest'
import { agentsCopy } from './copy'
import { agentSchema, passwordSchema } from './schema'
import { shopSchema } from '../shops/schema'
import { shopFormCopy } from '../shops/copy'

const f = agentsCopy.ru.form
const valid = {
  fullName: 'Ахмед', code: 'SL-101', phone: '+993 65 123456', whatsappPhone: '', routeNotes: '',
  dailyVisitPlan: '25', dailyAuditPlan: '20', regionId: 'r1', device: 'keep' as const, status: 'ACTIVE' as const,
  password: 'Kamil2026', confirmPassword: 'Kamil2026'
}
const messages = (r: { success: boolean, error?: { issues: Array<{ path: PropertyKey[], message: string }> } }) =>
  Object.fromEntries((r.error?.issues ?? []).map((i) => [String(i.path[0]), i.message]))

describe('agentSchema', () => {
  it('converts the phone and plans to what the API takes', () => {
    const r = agentSchema(f, true).parse(valid)
    expect(r.phone).toBe('+99365123456')
    expect(r.whatsappPhone).toBeNull()
    expect([r.dailyVisitPlan, r.dailyAuditPlan]).toEqual([25, 20])
  })

  it('reports audit plan > visit plan even while another field is wrong', () => {
    const errors = messages(agentSchema(f, true).safeParse({ ...valid, fullName: '', dailyAuditPlan: '40' }))
    expect(errors.fullName).toBe(f.errors.field)
    expect(errors.dailyAuditPlan).toBe(f.errors.plan)
  })

  it('needs a password with a letter and a digit only when adding', () => {
    expect(messages(agentSchema(f, true).safeParse({ ...valid, password: 'onlyletters', confirmPassword: 'onlyletters' })).password).toBe(f.errors.password)
    expect(agentSchema(f, false).safeParse({ ...valid, password: '', confirmPassword: '' }).success).toBe(true)
  })
})

describe('passwordSchema', () => {
  it('flags a mismatched confirmation even when the password is weak', () => {
    expect(messages(passwordSchema(f).safeParse({ password: 'abc', confirmPassword: 'abd' })).confirmPassword).toBe(f.errors.confirm)
  })
})

describe('shopSchema', () => {
  const c = shopFormCopy.ru
  it('keeps landlines, drops empty phone rows and needs a map point', () => {
    const base = { name: 'Shop', address: 'Street', agentId: '', point: { lat: 37.95, lng: 58.38 }, productIds: [], facadePhotoId: null }
    const r = shopSchema(c).parse({ ...base, phones: [{ phone: '+993 12 345678', label: '' }, { phone: '', label: '' }] })
    expect(r.phones.map((p) => p.phone)).toEqual(['+99312345678', null])
    expect(r.agentId).toBeNull()
    expect(messages(shopSchema(c).safeParse({ ...base, point: null, phones: [] })).point).toBe(c.errors.location)
  })
})
