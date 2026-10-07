import type { PrismaClient } from '../../generated/prisma/client.js'
import type { Storage } from '../../plugins/storage.js'
import { decodeCursor, encodeCursor } from '../../lib/pagination.js'
import { photoView } from '../photos/photo.view.js'

/** Bell activity feed (approved exception A6): violations and missed visits, derived by query. */
export class FeedService {
  private readonly prisma: PrismaClient
  private readonly storage: Storage
  constructor (prisma: PrismaClient, storage: Storage) {
    this.prisma = prisma
    this.storage = storage
  }

  async list (userId: string, cursor?: string, limit = 20) {
    const before = decodeCursor(cursor)?.at ?? null
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId }, select: { feedSeenAt: true } })
    const shop = { select: { id: true, name: true, code: true, address: true } }
    const agent = { select: { userId: true, fullName: true, code: true } }
    const [violations, missed, unreadV, unreadM] = await Promise.all([
      this.prisma.audit.findMany({
        where: { hasViolation: true, ...(before ? { finishedAtDevice: { lt: before } } : {}) },
        orderBy: { finishedAtDevice: 'desc' }, take: limit + 1,
        include: { shop, agent, photos: { where: { status: 'READY' }, orderBy: { takenAt: 'asc' }, take: 4 } }
      }),
      this.prisma.routeStop.findMany({
        where: { status: 'MISSED', ...(before ? { plannedAt: { lt: before } } : {}) },
        orderBy: { plannedAt: 'desc' }, take: limit + 1,
        include: { shop, route: { select: { agent } } }
      }),
      this.prisma.audit.count({ where: { hasViolation: true, ...(user.feedSeenAt ? { receivedAt: { gt: user.feedSeenAt } } : {}) } }),
      this.prisma.routeStop.count({ where: { status: 'MISSED', ...(user.feedSeenAt ? { updatedAt: { gt: user.feedSeenAt } } : {}) } })
    ])
    const merged = [
      ...violations.map((a) => ({ at: a.finishedAtDevice, id: a.id, a })),
      ...missed.map((m) => ({ at: m.plannedAt, id: m.id, m }))
    ].sort((x, y) => y.at.getTime() - x.at.getTime())
    const page = merged.slice(0, limit)
    const items = await Promise.all(page.map(async (v) => 'a' in v
      ? {
          type: 'VIOLATION' as const, id: v.a.id, at: v.a.finishedAtDevice.toISOString(), shop: v.a.shop,
          agent: { id: v.a.agent.userId, fullName: v.a.agent.fullName, code: v.a.agent.code }, comment: v.a.comment,
          photos: await Promise.all(v.a.photos.map((p) => photoView(this.storage, p)))
        }
      : { type: 'MISSED_VISIT' as const, id: v.m.id, at: v.m.plannedAt.toISOString(), shop: v.m.shop, agent: { id: v.m.route.agent.userId, fullName: v.m.route.agent.fullName, code: v.m.route.agent.code } }))
    const last = page.at(-1)
    return { items, nextCursor: merged.length > limit && last ? encodeCursor(last.at, last.id) : null, unreadCount: unreadV + unreadM }
  }

  async seen (userId: string) {
    await this.prisma.user.update({ where: { id: userId }, data: { feedSeenAt: new Date() } })
  }
}
