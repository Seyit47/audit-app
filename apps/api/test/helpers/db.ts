import type { FastifyInstance } from 'fastify'

const TABLES = [
  'LocationPing', 'AgentPosition', 'Export', 'Photo', 'RouteStop', 'Route', 'Audit', 'ShopProduct',
  'ShopAssignment', 'ShopContact', 'Shop', 'Product', 'ProductCategory', 'Device', 'RefreshToken',
  'Agent', 'User', 'Region'
]

/** Empties all domain tables (keeps migrations and the pg-boss schema). Resets settings to defaults. */
export async function resetDb (app: FastifyInstance): Promise<void> {
  await app.prisma.$executeRawUnsafe(`ALTER TABLE "Audit" DISABLE TRIGGER audit_immutable; ALTER TABLE "Photo" DISABLE TRIGGER audit_photo_guard;`)
  try {
    await app.prisma.$executeRawUnsafe(`TRUNCATE ${TABLES.map((t) => `"${t}"`).join(', ')} CASCADE`)
  } finally {
    await app.prisma.$executeRawUnsafe(`ALTER TABLE "Audit" ENABLE TRIGGER audit_immutable; ALTER TABLE "Photo" ENABLE TRIGGER audit_photo_guard;`)
  }
  await app.prisma.companySettings.upsert({ where: { id: 1 }, update: { companyName: 'COMPANY NAME', workStart: '00:00', workEnd: '23:59', timezone: 'Asia/Ashgabat', visitFrequencyDays: 7, defaultAuditRadiusM: 100, minGpsAccuracyM: 50, noSignalMinutes: 45 }, create: { id: 1, workStart: '00:00', workEnd: '23:59' } })
}
