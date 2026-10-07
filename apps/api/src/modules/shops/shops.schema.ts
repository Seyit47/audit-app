import { Type, type Static } from '@sinclair/typebox'

const Uuid = Type.String({ format: 'uuid' })
const Nullable = <T extends ReturnType<typeof Type.String>>(t: T) => Type.Union([t, Type.Null()])

export const ShopStatus = Type.Union([Type.Literal('PENDING_REVIEW'), Type.Literal('ACTIVE'), Type.Literal('INACTIVE')])

export const Contact = Type.Object({
  phone: Type.String({ pattern: '^\\+?[0-9 ()-]{6,20}$' }),
  label: Type.Optional(Nullable(Type.String({ maxLength: 60 })))
}, { additionalProperties: false })

const Editable = {
  name: Type.String({ minLength: 1, maxLength: 160 }),
  type: Type.Optional(Type.Union([Type.Literal('HYPERMARKET'), Type.Literal('SUPERMARKET'), Type.Literal('MARKET'), Type.Literal('MINIMARKET'), Type.Literal('OTHER')])),
  address: Type.String({ minLength: 1, maxLength: 300 }),
  addressDetail: Type.Optional(Nullable(Type.String({ maxLength: 300 }))),
  regionId: Type.Optional(Nullable(Uuid)),
  lat: Type.Number({ minimum: -90, maximum: 90 }),
  lng: Type.Number({ minimum: -180, maximum: 180 }),
  auditRadiusM: Type.Optional(Type.Integer({ minimum: 10, maximum: 1000 })),
  ownerName: Type.Optional(Nullable(Type.String({ maxLength: 120 }))),
  facadePhotoId: Type.Optional(Nullable(Uuid)),
  assignedAgentId: Type.Optional(Nullable(Uuid))
}

export const CreateShopBody = Type.Object({
  /** Client id (agent outbox): a repeated create returns the existing shop. */
  id: Type.Optional(Uuid),
  ...Editable,
  contacts: Type.Optional(Type.Array(Contact, { maxItems: 5 })),
  /** Agent creates: GPS accuracy of the captured location. */
  accuracyM: Type.Optional(Type.Number({ minimum: 0 }))
}, { additionalProperties: false })
export type CreateShopBody = Static<typeof CreateShopBody>

export const PatchShopBody = Type.Object({
  version: Type.Integer({ minimum: 1 }),
  ...Type.Partial(Type.Object(Editable)).properties,
  status: Type.Optional(ShopStatus)
}, { additionalProperties: false })
export type PatchShopBody = Static<typeof PatchShopBody>

export const ContactsBody = Type.Object({ contacts: Type.Array(Contact, { maxItems: 5 }) }, { additionalProperties: false })
export type ContactsBody = Static<typeof ContactsBody>

export const BulkAssignBody = Type.Object({ shopIds: Type.Array(Uuid, { minItems: 1, maxItems: 500 }), agentId: Nullable(Uuid) }, { additionalProperties: false })
export const BulkDeleteBody = Type.Object({ shopIds: Type.Array(Uuid, { minItems: 1, maxItems: 500 }) }, { additionalProperties: false })

export const ListShopsQuery = Type.Object({
  page: Type.Optional(Type.Integer({ minimum: 1 })),
  size: Type.Optional(Type.Integer({ minimum: 1, maximum: 100 })),
  q: Type.Optional(Type.String({ maxLength: 100 })),
  status: Type.Optional(ShopStatus),
  regionId: Type.Optional(Uuid),
  agentId: Type.Optional(Uuid),
  sort: Type.Optional(Type.Union([Type.Literal('name'), Type.Literal('code'), Type.Literal('lastVisitAt'), Type.Literal('createdAt')])),
  dir: Type.Optional(Type.Union([Type.Literal('asc'), Type.Literal('desc')])),
  /** Agent sync: changes since this instant, with tombstones. */
  updatedAfter: Type.Optional(Type.String({ format: 'date-time' }))
}, { additionalProperties: false })
export type ListShopsQuery = Static<typeof ListShopsQuery>

export const VisitsQuery = Type.Object({
  cursor: Type.Optional(Type.String()),
  limit: Type.Optional(Type.Integer({ minimum: 1, maximum: 50 }))
}, { additionalProperties: false })

export const IdParams = Type.Object({ id: Uuid })

export const MapQuery = Type.Object({
  agentIds: Type.Optional(Type.Array(Uuid)),
  regionIds: Type.Optional(Type.Array(Uuid)),
  ids: Type.Optional(Type.Array(Uuid)),
  status: Type.Optional(ShopStatus)
}, { additionalProperties: false })
export type MapQuery = Static<typeof MapQuery>
