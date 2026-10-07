import { Type, type Static } from '@sinclair/typebox'

const Uuid = Type.String({ format: 'uuid' })
const Status = Type.Union([Type.Literal('ACTIVE'), Type.Literal('INACTIVE'), Type.Literal('DRAFT')])

// Fields of Add Product (495:2311).
const Fields = {
  sku: Type.String({ minLength: 1, maxLength: 40 }),
  name: Type.String({ minLength: 1, maxLength: 200 }),
  categoryId: Uuid,
  brand: Type.Optional(Type.Union([Type.String({ maxLength: 120 }), Type.Null()])),
  /** Retail price in the company currency (TMT), e.g. 185.00. */
  retailPrice: Type.Number({ minimum: 0, maximum: 10_000_000 }),
  description: Type.Optional(Type.Union([Type.String({ maxLength: 4000 }), Type.Null()])),
  imageId: Type.Optional(Type.Union([Uuid, Type.Null()])),
  status: Type.Optional(Status),
  stockTracked: Type.Optional(Type.Boolean()),
  stockQty: Type.Optional(Type.Integer({ minimum: 0 })),
  minStockAlert: Type.Optional(Type.Integer({ minimum: 0 }))
}

export const CreateProductBody = Type.Object(Fields, { additionalProperties: false })
export type CreateProductBody = Static<typeof CreateProductBody>
export const PatchProductBody = Type.Partial(Type.Object(Fields), { additionalProperties: false })
export type PatchProductBody = Static<typeof PatchProductBody>

export const ListProductsQuery = Type.Object({
  page: Type.Optional(Type.Integer({ minimum: 1 })),
  size: Type.Optional(Type.Integer({ minimum: 1, maximum: 100 })),
  q: Type.Optional(Type.String({ maxLength: 100 })),
  status: Type.Optional(Status),
  categoryId: Type.Optional(Uuid),
  regionId: Type.Optional(Uuid)
}, { additionalProperties: false })
export type ListProductsQuery = Static<typeof ListProductsQuery>

export const ShopProductsBody = Type.Object({ productIds: Type.Array(Uuid, { maxItems: 1000, uniqueItems: true }) }, { additionalProperties: false })
export const IdParams = Type.Object({ id: Uuid })
