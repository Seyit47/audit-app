import { z } from 'zod'
import { int, required, whenValid } from '@/lib/form'
import type { SettingsCopy } from './copy'

/** Company settings: each rule in its range, and the workday ending after it starts. */
export function settingsSchema (copy: SettingsCopy) {
  const range = (min: number, max: number) => int(min, max, copy.errors.range.replace('{min}', String(min)).replace('{max}', String(max)))
  const base = z.object({
    companyName: required(copy.errors.field).max(120),
    logoPhotoId: z.string().nullable(),
    workStart: z.string(),
    workEnd: z.string(),
    timezone: z.string(),
    visitFrequencyDays: range(1, 90),
    defaultAuditRadiusM: range(10, 1000),
    minGpsAccuracyM: range(5, 200),
    noSignalMinutes: range(5, 240)
  })
  return base.refine((v) => v.workEnd > v.workStart, { path: ['workEnd'], message: copy.errors.hours, ...whenValid(base, ['workStart', 'workEnd']) })
}
export type SettingsValues = z.input<ReturnType<typeof settingsSchema>>
