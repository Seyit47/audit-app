import { Type, type Static } from '@sinclair/typebox'

// Fields of Add Salesman (Figma 495:3932, data-model.md "agents").
const Fields = {
  fullName: Type.String({ minLength: 1, maxLength: 120 }),
  phone: Type.String({ pattern: '^\\+?[0-9 ()-]{6,20}$' }),
  whatsappPhone: Type.Optional(Type.Union([Type.String({ pattern: '^\\+?[0-9 ()-]{6,20}$' }), Type.Null()])),
  regionId: Type.String({ format: 'uuid' }),
  photoId: Type.Optional(Type.Union([Type.String({ format: 'uuid' }), Type.Null()])),
  routeNotes: Type.Optional(Type.Union([Type.String({ maxLength: 2000 }), Type.Null()])),
  dailyVisitPlan: Type.Optional(Type.Integer({ minimum: 1, maximum: 100 })),
  dailyAuditPlan: Type.Optional(Type.Integer({ minimum: 0, maximum: 100 })),
  workStatus: Type.Optional(Type.Union([Type.Literal('ACTIVE'), Type.Literal('ON_LEAVE')])),
  imeiLabel: Type.Optional(Type.Union([Type.String({ maxLength: 64 }), Type.Null()]))
}

/** A password the admin chooses for the salesman (otherwise one is generated and shown once). */
const Password = Type.String({ minLength: 8, maxLength: 128 })

export const CreateAgentBody = Type.Object({
  ...Fields,
  /** "Табельный номер / Код": generated from the SL- sequence when omitted. */
  code: Type.Optional(Type.String({ pattern: '^[A-Za-z0-9-]{2,20}$' })),
  password: Type.Optional(Password)
}, { additionalProperties: false })
export type CreateAgentBody = Static<typeof CreateAgentBody>

/** "Изменить пароль": the new password the admin typed. */
export const PasswordBody = Type.Object({ password: Password }, { additionalProperties: false })
export type PasswordBody = Static<typeof PasswordBody>

export const PatchAgentBody = Type.Object({
  ...Type.Partial(Type.Object(Fields)).properties,
  code: Type.Optional(Type.String({ pattern: '^[A-Za-z0-9-]{2,20}$' })),
  version: Type.Integer({ minimum: 1 }),
  active: Type.Optional(Type.Boolean())
}, { additionalProperties: false })
export type PatchAgentBody = Static<typeof PatchAgentBody>

export const DeviceBody = Type.Object({ imeiLabel: Type.Optional(Type.Union([Type.String({ maxLength: 64 }), Type.Null()])) }, { additionalProperties: false })
export type DeviceBody = Static<typeof DeviceBody>

const Day = Type.String({ pattern: '^\\d{4}-\\d{2}-\\d{2}$' })
export const ListAgentsQuery = Type.Object({
  page: Type.Optional(Type.Integer({ minimum: 1 })),
  size: Type.Optional(Type.Integer({ minimum: 1, maximum: 100 })),
  q: Type.Optional(Type.String({ maxLength: 100 })),
  status: Type.Optional(Type.Union([Type.Literal('ACTIVE'), Type.Literal('ON_LEAVE'), Type.Literal('INACTIVE')])),
  regionId: Type.Optional(Type.String({ format: 'uuid' })),
  from: Type.Optional(Day),
  to: Type.Optional(Day),
  sort: Type.Optional(Type.Union([Type.Literal('fullName'), Type.Literal('code'), Type.Literal('locations'), Type.Literal('visits'), Type.Literal('photos'), Type.Literal('lastActivityAt')])),
  dir: Type.Optional(Type.Union([Type.Literal('asc'), Type.Literal('desc')]))
}, { additionalProperties: false })
export type ListAgentsQuery = Static<typeof ListAgentsQuery>

export const IdParams = Type.Object({ id: Type.String({ format: 'uuid' }) })

export const PeriodQuery = Type.Object({ from: Type.Optional(Day), to: Type.Optional(Day) }, { additionalProperties: false })
export const DateQuery = Type.Object({ date: Type.Optional(Day) }, { additionalProperties: false })
export const CursorQuery = Type.Object({ cursor: Type.Optional(Type.String()), limit: Type.Optional(Type.Integer({ minimum: 1, maximum: 50 })) }, { additionalProperties: false })
