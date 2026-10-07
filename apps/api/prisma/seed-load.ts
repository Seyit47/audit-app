// Load data for the performance pass (T129, SC-005): 10,000 shops, 100,000 photos, 30,000 audits,
// 100 agents. Run against an empty, migrated database: `DATABASE_URL=… pnpm seed:load`.
import 'dotenv/config'
import { createPrisma } from '../src/lib/prisma.js'
import { newId } from '../src/lib/ids.js'

const prisma = createPrisma(process.env.DATABASE_URL!)
const SHOPS = 10_000
const AGENTS = 100
const AUDITS = 30_000
const PHOTOS = 100_000
const batch = async <T> (rows: T[], insert: (chunk: T[]) => Promise<unknown>, size = 5000) => {
  for (let i = 0; i < rows.length; i += size) await insert(rows.slice(i, i + size))
}

await prisma.companySettings.upsert({ where: { id: 1 }, update: {}, create: { id: 1 } })
const regions = Array.from({ length: 8 }, (_, i) => ({ id: newId(), name: `Load Region ${i + 1}` }))
await prisma.region.createMany({ data: regions })
const adminId = newId()
await prisma.user.create({ data: { id: adminId, role: 'ADMIN', email: 'load-admin@audit.local', passwordHash: 'x' } })

const agents = Array.from({ length: AGENTS }, (_, i) => ({ id: newId(), i }))
await prisma.user.createMany({ data: agents.map((a) => ({ id: a.id, role: 'AGENT' as const, phone: `+9936${String(1_000_000 + a.i).padStart(7, '0')}`, passwordHash: 'x' })) })
await prisma.agent.createMany({ data: agents.map((a) => ({ userId: a.id, code: `LD-${a.i}`, fullName: `Load Agent ${a.i}`, phone: `+9936${String(1_000_000 + a.i).padStart(7, '0')}`, regionId: regions[a.i % regions.length].id })) })

const now = Date.now()
const shops = Array.from({ length: SHOPS }, (_, i) => ({
  id: newId(), code: `LS-${i}`, name: `Load Shop ${i}`, address: `Street ${i % 500}, ${i}`, regionId: regions[i % regions.length].id,
  lat: 37.85 + (i % 100) * 0.002, lng: 58.25 + Math.floor(i / 100) * 0.003, auditRadiusM: 100,
  assignedAgentId: agents[i % AGENTS].id, status: 'ACTIVE' as const, createdById: adminId,
  lastVisitAt: new Date(now - (i % 30) * 86_400_000), nextDueAt: new Date(now + ((i % 14) - 7) * 86_400_000)
}))
await batch(shops, (c) => prisma.shop.createMany({ data: c }))

const audits = Array.from({ length: AUDITS }, (_, i) => {
  const shop = shops[i % SHOPS]
  const at = new Date(now - (i % 90) * 86_400_000 - (i % 600) * 60_000)
  return { id: newId(), shopId: shop.id, agentId: shop.assignedAgentId, startedAtDevice: new Date(at.getTime() - 900_000), finishedAtDevice: at, durationMin: 15,
    lat: shop.lat, lng: shop.lng, gpsAccuracyM: 6, distanceM: 10, withinRadius: true, comment: 'Load audit', hasViolation: i % 9 === 0 }
})
await batch(audits, (c) => prisma.audit.createMany({ data: c }))

const photos = Array.from({ length: PHOTOS }, (_, i) => {
  const a = audits[i % AUDITS]
  const id = newId()
  return { id, kind: 'AUDIT' as const, auditId: a.id, shopId: a.shopId, uploadedById: a.agentId, storageKey: `load/${id}.jpg`, mime: 'image/jpeg', sizeBytes: 200_000,
    sha256: 'a'.repeat(64), takenAt: a.finishedAtDevice, status: 'READY' as const, verifiedAt: i % 4 === 0 ? null : a.finishedAtDevice }
})
await batch(photos, (c) => prisma.photo.createMany({ data: c }))
console.log(`Seeded ${SHOPS} shops, ${AGENTS} agents, ${AUDITS} audits, ${PHOTOS} photos.`)
await prisma.$disconnect()
