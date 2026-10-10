import { z } from 'zod'
import { int, phone, required, whenValid } from '@/lib/form'
import type { AgentsCopy } from './copy'

type FormCopy = AgentsCopy['form']

/** The salesman password rules, the same as the API (`agents.schema.ts`). */
export const passwordRules = (password: string, confirm: string) => ({
  length: password.length >= 8,
  letter: /\p{L}/u.test(password),
  digit: /\d/.test(password),
  match: password !== '' && password === confirm
})

const passwordPair = (f: FormCopy) => z.object({
  password: z.string().refine((v) => { const r = passwordRules(v, v); return r.length && r.letter && r.digit }, f.errors.password),
  confirmPassword: z.string()
})

/** "Изменить пароль" (and the password part of Add salesman). */
export function passwordSchema (f: FormCopy) {
  const base = passwordPair(f)
  return base.refine((v) => v.confirmPassword === v.password, { path: ['confirmPassword'], message: f.errors.confirm, ...whenValid(base, ['confirmPassword']) })
}
export type PasswordValues = z.input<ReturnType<typeof passwordSchema>>

/** Add / edit salesman (495:3932). The password pair only when adding. */
export function agentSchema (f: FormCopy, adding: boolean) {
  const base = z.object({
    fullName: required(f.errors.field),
    code: required(f.errors.field).regex(/^[A-Za-z0-9-]{2,20}$/, f.errors.code),
    phone: phone('mobile', { required: f.errors.field, invalid: f.errors.phone }),
    whatsappPhone: phone('mobile', { required: f.errors.field, invalid: f.errors.phone }, true),
    routeNotes: z.string().trim().transform((v) => v || null),
    dailyVisitPlan: int(1, 100, f.errors.visitPlan),
    dailyAuditPlan: int(0, 100, f.errors.visitPlan),
    regionId: required(f.errors.field),
    device: z.enum(['keep', 'reset']),
    status: z.enum(['ACTIVE', 'ON_LEAVE', 'ARCHIVED']),
    // Set only when adding; an edit leaves them empty and unchecked.
    password: adding ? passwordPair(f).shape.password : z.string(),
    confirmPassword: z.string()
  })
  return base
    .refine((v) => v.dailyAuditPlan <= v.dailyVisitPlan, { path: ['dailyAuditPlan'], message: f.errors.plan, ...whenValid(base, ['dailyVisitPlan', 'dailyAuditPlan']) })
    .refine((v) => !adding || v.confirmPassword === v.password, { path: ['confirmPassword'], message: f.errors.confirm, ...whenValid(base, ['confirmPassword']) })
}
export type AgentValues = z.input<ReturnType<typeof agentSchema>>
