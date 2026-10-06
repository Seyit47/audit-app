import { Type, type Static } from '@sinclair/typebox'

export const ExportType = Type.Union([
  Type.Literal('SHOPS_XLSX'), Type.Literal('AGENTS_XLSX'), Type.Literal('PRODUCTS_XLSX'),
  Type.Literal('AGENT_REPORT_PDF'), Type.Literal('AGENT_REPORT_XLSX')
])

export const CreateExportBody = Type.Object({
  type: ExportType,
  /** The list filters of the page that started the export, plus `locale` for the headers. */
  params: Type.Optional(Type.Record(Type.String(), Type.Union([Type.String(), Type.Number(), Type.Null()])))
}, { additionalProperties: false })
export type CreateExportBody = Static<typeof CreateExportBody>

export const IdParams = Type.Object({ id: Type.String({ format: 'uuid' }) })
