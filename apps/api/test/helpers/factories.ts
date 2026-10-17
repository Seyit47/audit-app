import argon2 from 'argon2'
import type { FastifyInstance } from 'fastify'
import { newId } from '../../src/lib/ids.js'

export const PASSWORD = 'Passw0rd!'
let hash: string | undefined
const passwordHash = async () => (hash ??= await argon2.hash(PASSWORD, { type: argon2.argon2id }))
let seq = 0
const next = () => ++seq

export async function district (app: FastifyInstance, name = `District ${next()}`) {
  return app.prisma.district.create({ data: { id: newId(), name } })
}

export async function admin (app: FastifyInstance, email = `admin${next()}@test.local`) {
  return app.prisma.user.create({ data: { id: newId(), role: 'ADMIN', email, passwordHash: await passwordHash() } })
}

export async function agent (app: FastifyInstance, opts: { installId?: string, workStatus?: 'ACTIVE' | 'ON_LEAVE' } = {}) {
  const id = newId()
  const n = next()
  const phone = `+9936500${String(n).padStart(4, '0')}`
  await app.prisma.user.create({ data: { id, role: 'AGENT', phone, passwordHash: await passwordHash() } })
  return app.prisma.agent.create({
    data: {
      userId: id, code: `SL-${900 + n}`, fullName: `Agent ${n}`, phone, workStatus: opts.workStatus ?? 'ACTIVE',
      device: { create: { id: newId(), installId: opts.installId ?? null, model: 'Test Phone' } }
    },
    include: { user: true }
  })
}

export async function shop (app: FastifyInstance, opts: { agentId?: string | null, districtId?: string, lat?: number, lng?: number, status?: 'ACTIVE' | 'INACTIVE' | 'PENDING_REVIEW', createdById: string, nextDueAt?: Date }) {
  const id = newId()
  const n = next()
  const s = await app.prisma.shop.create({
    data: {
      id, code: `CL-${900 + n}`, name: `Shop ${n}`, type: 'MARKET', address: `Street ${n}`, districtId: opts.districtId ?? null,
      lat: opts.lat ?? 37.95, lng: opts.lng ?? 58.38, auditRadiusM: 100, ownerName: 'Owner', status: opts.status ?? 'ACTIVE',
      createdById: opts.createdById, nextDueAt: opts.nextDueAt ?? new Date()
    }
  })
  if (opts.agentId) await app.prisma.shopAssignment.create({ data: { id: newId(), shopId: id, agentId: opts.agentId, from: new Date(Date.now() - 86_400_000) } })
  return s
}

export async function productCategory (app: FastifyInstance, name = `Category ${next()}`) {
  return app.prisma.productCategory.create({ data: { id: newId(), name } })
}
