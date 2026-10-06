import { Type, type Static } from '@sinclair/typebox'

export const LoginBody = Type.Object({
  login: Type.String({ minLength: 1, maxLength: 200, description: 'Email (admins) or phone (agents)' }),
  password: Type.String({ minLength: 1, maxLength: 200 }),
  device: Type.Optional(Type.Object({
    installId: Type.String({ minLength: 1, maxLength: 200 }),
    model: Type.String({ maxLength: 200 })
  }))
}, { additionalProperties: false })
export type LoginBody = Static<typeof LoginBody>

export const RefreshBody = Type.Object({ refreshToken: Type.String({ minLength: 1 }) }, { additionalProperties: false })
export type RefreshBody = Static<typeof RefreshBody>

const SessionUser = Type.Object({
  id: Type.String(),
  role: Type.Union([Type.Literal('ADMIN'), Type.Literal('AGENT')]),
  agentId: Type.Union([Type.String(), Type.Null()])
})

export const TokensResponse = Type.Object({
  accessToken: Type.String(),
  refreshToken: Type.String(),
  user: SessionUser
})

const Image = Type.Object({
  id: Type.String(),
  url: Type.String(),
  previewUrl400: Type.Union([Type.String(), Type.Null()]),
  previewUrl1200: Type.Union([Type.String(), Type.Null()]),
  width: Type.Union([Type.Integer(), Type.Null()]),
  height: Type.Union([Type.Integer(), Type.Null()]),
  takenAt: Type.String()
})

export const MeResponse = Type.Object({
  user: Type.Object({
    id: Type.String(),
    role: Type.Union([Type.Literal('ADMIN'), Type.Literal('AGENT')]),
    email: Type.Union([Type.String(), Type.Null()]),
    phone: Type.Union([Type.String(), Type.Null()])
  }),
  agent: Type.Union([Type.Null(), Type.Object({
    code: Type.String(),
    fullName: Type.String(),
    phone: Type.String(),
    region: Type.Object({ id: Type.String(), name: Type.String() }),
    dailyVisitPlan: Type.Integer(),
    dailyAuditPlan: Type.Integer(),
    workStatus: Type.Union([Type.Literal('ACTIVE'), Type.Literal('ON_LEAVE')])
  })]),
  config: Type.Object({
    companyName: Type.String(),
    logo: Type.Union([Image, Type.Null()]),
    defaultAuditRadiusM: Type.Integer(),
    minGpsAccuracyM: Type.Integer(),
    workStart: Type.String(),
    workEnd: Type.String(),
    timezone: Type.String()
  })
})
