import { Type, type Static } from '@sinclair/typebox'

const Uuid = Type.String({ format: 'uuid' })

export const CheckStartBody = Type.Object({
  shopId: Uuid,
  lat: Type.Number({ minimum: -90, maximum: 90 }),
  lng: Type.Number({ minimum: -180, maximum: 180 }),
  accuracyM: Type.Number({ minimum: 0 })
}, { additionalProperties: false })
export type CheckStartBody = Static<typeof CheckStartBody>

export const CreateAuditBody = Type.Object({
  id: Uuid,
  shopId: Uuid,
  routeStopId: Type.Optional(Type.Union([Uuid, Type.Null()])),
  startedAt: Type.String({ format: 'date-time' }),
  finishedAt: Type.String({ format: 'date-time' }),
  lat: Type.Number({ minimum: -90, maximum: 90 }),
  lng: Type.Number({ minimum: -180, maximum: 180 }),
  accuracyM: Type.Number({ minimum: 0 }),
  comment: Type.String({ minLength: 1, maxLength: 4000 }),
  hasViolation: Type.Boolean(),
  photoIds: Type.Array(Uuid, { minItems: 1, maxItems: 20, uniqueItems: true })
}, { additionalProperties: false })
export type CreateAuditBody = Static<typeof CreateAuditBody>

export const ListAuditsQuery = Type.Object({
  shopId: Type.Optional(Uuid),
  agentId: Type.Optional(Uuid),
  from: Type.Optional(Type.String({ format: 'date-time' })),
  to: Type.Optional(Type.String({ format: 'date-time' })),
  hasViolation: Type.Optional(Type.Boolean()),
  cursor: Type.Optional(Type.String()),
  limit: Type.Optional(Type.Integer({ minimum: 1, maximum: 100 }))
}, { additionalProperties: false })
export type ListAuditsQuery = Static<typeof ListAuditsQuery>

export const IdParams = Type.Object({ id: Uuid })
