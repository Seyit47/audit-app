import type { PrismaClient } from '../../generated/prisma/client.js'
import { newId } from '../../lib/ids.js'

export class AuthRepository {
  private readonly prisma: PrismaClient
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  findByLogin (login: string) {
    const where = login.includes('@') ? { email: login.toLowerCase() } : { phone: login.replace(/[\s()-]/g, '') }
    return this.prisma.user.findUnique({ where, include: { agent: { include: { device: true } } } })
  }

  findUser (id: string) {
    return this.prisma.user.findUnique({ where: { id }, select: { id: true, status: true, deactivatedAt: true } })
  }

  bindDevice (agentId: string, installId: string, model: string) {
    return this.prisma.device.upsert({
      where: { agentId },
      update: { installId, model, boundAt: new Date() },
      create: { id: newId(), agentId, installId, model, boundAt: new Date() }
    })
  }

  createRefreshToken (data: { userId: string, tokenHash: string, mobile: boolean, deviceId: string | null, expiresAt: Date }) {
    return this.prisma.refreshToken.create({ data: { id: newId(), ...data } })
  }

  findRefreshToken (tokenHash: string) {
    return this.prisma.refreshToken.findUnique({ where: { tokenHash }, include: { user: { select: { id: true, role: true, status: true } } } })
  }

  /** Revokes a token only if it is still live, so a concurrent reuse can't rotate twice. */
  async revokeIfLive (id: string): Promise<boolean> {
    const { count } = await this.prisma.refreshToken.updateMany({ where: { id, revokedAt: null }, data: { revokedAt: new Date() } })
    return count === 1
  }

  revokeByHash (userId: string, tokenHash: string) {
    return this.prisma.refreshToken.updateMany({ where: { userId, tokenHash, revokedAt: null }, data: { revokedAt: new Date() } })
  }

  revokeAll (userId: string) {
    return this.prisma.refreshToken.updateMany({ where: { userId, revokedAt: null }, data: { revokedAt: new Date() } })
  }

  touch (userId: string) {
    return this.prisma.user.update({ where: { id: userId }, data: { lastActiveAt: new Date() } })
  }

  me (userId: string) {
    return this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { id: true, role: true, email: true, phone: true, agent: { include: { region: true } } }
    })
  }
}
