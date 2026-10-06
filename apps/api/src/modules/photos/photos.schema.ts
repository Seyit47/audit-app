import { Type, type Static } from '@sinclair/typebox'

export const CreateUploadBody = Type.Object({
  id: Type.String({ format: 'uuid' }),
  kind: Type.Union([Type.Literal('AUDIT'), Type.Literal('FACADE'), Type.Literal('PRODUCT'), Type.Literal('AVATAR'), Type.Literal('LOGO'), Type.Literal('ADMIN_UPLOAD')]),
  mime: Type.Union([Type.Literal('image/jpeg'), Type.Literal('image/png'), Type.Literal('image/webp')]),
  sizeBytes: Type.Integer({ minimum: 1 }),
  sha256: Type.String({ pattern: '^[a-f0-9]{64}$' }),
  takenAt: Type.String({ format: 'date-time' }),
  lat: Type.Optional(Type.Number()),
  lng: Type.Optional(Type.Number()),
  accuracyM: Type.Optional(Type.Number({ minimum: 0 })),
  shopId: Type.Optional(Type.String({ format: 'uuid' }))
}, { additionalProperties: false })
export type CreateUploadBody = Static<typeof CreateUploadBody>

export const IdParams = Type.Object({ id: Type.String({ format: 'uuid' }) })
