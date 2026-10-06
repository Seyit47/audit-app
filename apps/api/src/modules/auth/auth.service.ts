import argon2 from 'argon2'
import { createHash, randomBytes } from 'node:crypto'
import type { AuthUser } from '../../plugins/auth.js'
import type { Storage } from '../../plugins/storage.js'
import { AppError } from '../../lib/app-error.js'
import type { SettingsService } from '../settings/settings.service.js'
import type { PhotosRepository } from '../photos/photos.repository.js'
import { photoView } from '../photos/photo.view.js'
import type { AuthRepository } from './auth.repository.js'
import type { LoginBody } from './auth.schema.js'
import { LoginThrottle } from './login-throttle.js'

const HOUR = 3_600_000
export const IDLE_LIMIT_MS = { web: 12 * HOUR, mobile: 30 * 24 * HOUR }
/** Deactivated agents may still submit data recorded before deactivation for this long (api.md). */
export const DEACTIVATION_GRACE_MS = 72 * HOUR

type Sign = (payload: { sub: string, role: 'ADMIN' | 'AGENT', agentId?: string }) => string

const unauthenticated = (message = 'Invalid credentials') => new AppError(401, 'UNAUTHENTICATED', message)
const sha256 = (value: string) => createHash('sha256').update(value).digest('hex')

/** Sign-in, rotating refresh tokens with idle expiry, device binding (research R-05). */
export class AuthService {
  private readonly repo: AuthRepository
  private readonly sign: Sign
  private readonly settings: SettingsService
  private readonly photos: PhotosRepository
  private readonly storage: Storage
  private readonly throttle = new LoginThrottle()
  constructor (repo: AuthRepository, sign: Sign, settings: SettingsService, photos: PhotosRepository, storage: Storage) {
    this.repo = repo
    this.sign = sign
    this.settings = settings
    this.photos = photos
    this.storage = storage
  }

  async login (body: LoginBody, ip: string) {
    const key = `${ip}|${body.login.toLowerCase()}`
    if (this.throttle.isBlocked(key)) throw new AppError(429, 'RATE_LIMITED', 'Too many failed sign-in attempts')

    const user = await this.repo.findByLogin(body.login)
    const ok = user != null && user.status === 'ACTIVE' && await argon2.verify(user.passwordHash, body.password)
    if (!ok) {
      this.throttle.fail(key)
      throw unauthenticated()
    }
    this.throttle.reset(key)

    let deviceId: string | null = null
    if (user.role === 'AGENT') {
      if (body.device == null) throw new AppError(400, 'VALIDATION_FAILED', 'Agents must sign in from the app with a device')
      const bound = user.agent?.device?.installId
      if (bound != null && bound !== body.device.installId) {
        throw new AppError(403, 'DEVICE_NOT_BOUND', 'This account is bound to another device')
      }
      deviceId = (await this.repo.bindDevice(user.id, bound ?? body.device.installId, body.device.model)).id
    }
    await this.repo.touch(user.id)
    return this.issue(user.id, user.role, body.device != null, deviceId)
  }

  async refresh (refreshToken: string) {
    const token = await this.repo.findRefreshToken(sha256(refreshToken))
    const idleLimit = token?.mobile === true ? IDLE_LIMIT_MS.mobile : IDLE_LIMIT_MS.web
    if (token == null || token.revokedAt != null || !this.mayRefresh(token.user) ||
        Date.now() - token.lastUsedAt.getTime() > idleLimit) {
      throw unauthenticated('Session expired')
    }
    if (!await this.repo.revokeIfLive(token.id)) throw unauthenticated('Session expired')
    await this.repo.touch(token.userId)
    return this.issue(token.user.id, token.user.role, token.mobile, token.deviceId)
  }

  /** Active users, and deactivated ones within the grace period (their requests stay limited to `grace` routes). */
  private mayRefresh (user: { status: string, deactivatedAt: Date | null }): boolean {
    if (user.status === 'ACTIVE') return true
    return user.deactivatedAt != null && Date.now() - user.deactivatedAt.getTime() <= DEACTIVATION_GRACE_MS
  }

  async logout (user: AuthUser, refreshToken: string) {
    await this.repo.revokeByHash(user.id, sha256(refreshToken))
  }

  /**
   * Called by the auth guard for every authenticated request. Deactivated users are refused,
   * except outbox submissions (`grace` routes) within 72 h of deactivation.
   */
  async checkAccount (user: AuthUser, grace: boolean): Promise<void> {
    const account = await this.repo.findUser(user.id)
    if (account == null) throw unauthenticated('Account not found')
    if (account.status === 'ACTIVE') return
    const since = account.deactivatedAt
    if (!grace || since == null || Date.now() - since.getTime() > DEACTIVATION_GRACE_MS) throw unauthenticated('Account deactivated')
    user.deactivatedAt = since
  }

  async me (user: AuthUser) {
    const [me, settings] = await Promise.all([this.repo.me(user.id), this.settings.get()])
    const logo = settings.logoPhotoId == null ? null : await this.photos.findById(settings.logoPhotoId)
    return {
      user: { id: me.id, role: me.role, email: me.email, phone: me.phone },
      agent: me.agent == null
        ? null
        : {
            code: me.agent.code,
            fullName: me.agent.fullName,
            phone: me.agent.phone,
            region: { id: me.agent.region.id, name: me.agent.region.name },
            dailyVisitPlan: me.agent.dailyVisitPlan,
            dailyAuditPlan: me.agent.dailyAuditPlan,
            workStatus: me.agent.workStatus
          },
      config: {
        companyName: settings.companyName,
        logo: logo?.status === 'READY' ? await photoView(this.storage, logo) : null,
        defaultAuditRadiusM: settings.defaultAuditRadiusM,
        minGpsAccuracyM: settings.minGpsAccuracyM,
        workStart: settings.workStart,
        workEnd: settings.workEnd,
        timezone: settings.timezone
      }
    }
  }

  private async issue (userId: string, role: 'ADMIN' | 'AGENT', mobile: boolean, deviceId: string | null) {
    const refreshToken = randomBytes(32).toString('base64url')
    const idle = mobile ? IDLE_LIMIT_MS.mobile : IDLE_LIMIT_MS.web
    await this.repo.createRefreshToken({ userId, tokenHash: sha256(refreshToken), mobile, deviceId, expiresAt: new Date(Date.now() + idle) })
    const agentId = role === 'AGENT' ? userId : null
    return {
      accessToken: this.sign(agentId != null ? { sub: userId, role, agentId } : { sub: userId, role }),
      refreshToken,
      user: { id: userId, role, agentId }
    }
  }
}
