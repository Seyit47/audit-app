import { Type, type Static } from '@sinclair/typebox'

const hhmm = Type.String({ pattern: '^([01]\\d|2[0-3]):[0-5]\\d$' })

export const SettingsPatch = Type.Object({
  companyName: Type.Optional(Type.String({ minLength: 1, maxLength: 120 })),
  logoPhotoId: Type.Optional(Type.Union([Type.String({ format: 'uuid' }), Type.Null()])),
  workStart: Type.Optional(hhmm),
  workEnd: Type.Optional(hhmm),
  timezone: Type.Optional(Type.String({ minLength: 3 })),
  visitFrequencyDays: Type.Optional(Type.Integer({ minimum: 1, maximum: 90 })),
  defaultAuditRadiusM: Type.Optional(Type.Integer({ minimum: 10, maximum: 1000 })),
  minGpsAccuracyM: Type.Optional(Type.Integer({ minimum: 5, maximum: 200 })),
  noSignalMinutes: Type.Optional(Type.Integer({ minimum: 5, maximum: 240 }))
}, { additionalProperties: false })
export type SettingsPatch = Static<typeof SettingsPatch>
