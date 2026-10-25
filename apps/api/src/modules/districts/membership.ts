import type { Prisma } from '../../generated/prisma/client.js'
import { newId } from '../../lib/ids.js'

type Tx = Prisma.TransactionClient

/**
 * Agents work districts: an agent linked to a district is assigned every shop in it. These keep the assignment
 * rows in step with the links (rows opened this way carry `viaDistrictId`; rows made by hand carry null and
 * are never touched here). Shops' updatedAt moves so the agents' phones pick the change up.
 */

/** Opens assignment rows for [agentIds] on [shopIds] where the agent has none open yet. */
async function open (tx: Tx, pairs: Array<{ shopId: string, agentId: string, viaDistrictId: string }>) {
  if (pairs.length === 0) return
  const shopIds = [...new Set(pairs.map((p) => p.shopId))]
  const have = new Set((await tx.shopAssignment.findMany({ where: { shopId: { in: shopIds }, to: null }, select: { shopId: true, agentId: true } }))
    .map((a) => `${a.shopId}/${a.agentId}`))
  const now = new Date()
  const add = pairs.filter((p) => !have.has(`${p.shopId}/${p.agentId}`)).map((p) => ({ id: newId(), ...p, from: now }))
  if (add.length === 0) return
  await tx.shopAssignment.createMany({ data: add })
  await tx.shop.updateMany({ where: { id: { in: [...new Set(add.map((a) => a.shopId))] } }, data: { updatedAt: now } })
}

/** Closes the rows that follow [districtIds] for [agentId] (all agents when null). */
async function close (tx: Tx, where: Prisma.ShopAssignmentWhereInput) {
  const rows = await tx.shopAssignment.findMany({ where: { ...where, to: null, viaDistrictId: { not: null } }, select: { id: true, shopId: true } })
  if (rows.length === 0) return
  const now = new Date()
  await tx.shopAssignment.updateMany({ where: { id: { in: rows.map((r) => r.id) } }, data: { to: now } })
  await tx.shop.updateMany({ where: { id: { in: [...new Set(rows.map((r) => r.shopId))] } }, data: { updatedAt: now } })
}

/** Makes [districtIds] the agent's districts: shops of districts they leave are taken away, shops of new ones given. */
export async function setAgentDistricts (tx: Tx, agentId: string, districtIds: string[]) {
  const current = (await tx.agentDistrict.findMany({ where: { agentId }, select: { districtId: true } })).map((d) => d.districtId)
  const removed = current.filter((d) => !districtIds.includes(d))
  const added = districtIds.filter((d) => !current.includes(d))
  if (removed.length > 0) {
    await tx.agentDistrict.deleteMany({ where: { agentId, districtId: { in: removed } } })
    await close(tx, { agentId, viaDistrictId: { in: removed } })
  }
  if (added.length > 0) {
    await tx.agentDistrict.createMany({ data: added.map((districtId) => ({ agentId, districtId })) })
    await giveDistrictShops(tx, agentId, added)
  }
}

/** The shops of [districtIds] to [agentId] (an agent linked, or reactivated). */
export async function giveDistrictShops (tx: Tx, agentId: string, districtIds: string[]) {
  const shops = await tx.shop.findMany({ where: { districtId: { in: districtIds }, deletedAt: null }, select: { id: true, districtId: true } })
  await open(tx, shops.map((s) => ({ shopId: s.id, agentId, viaDistrictId: s.districtId! })))
}

/** Shops moved into [districtId] (null: out of any): its agents get them; the old district's agents lose them. */
export async function shopsMovedToDistrict (tx: Tx, shopIds: string[], districtId: string | null) {
  await close(tx, { shopId: { in: shopIds }, ...(districtId == null ? {} : { viaDistrictId: { not: districtId } }) })
  if (districtId == null) return
  const agents = await tx.agentDistrict.findMany({ where: { districtId, agent: { user: { status: 'ACTIVE' } } }, select: { agentId: true } })
  await open(tx, shopIds.flatMap((shopId) => agents.map((a) => ({ shopId, agentId: a.agentId, viaDistrictId: districtId }))))
}
