import type { PrismaClient } from '../../lib/prisma.js'
import type { CompanySettings } from '../../generated/prisma/client.js'
import { AppError } from '../../lib/app-error.js'
import type { SettingsPatch } from './settings.schema.js'

const CACHE_MS = 60_000
type Listener = (s: CompanySettings) => Promise<void>

/** Company settings (approved exception A4), cached for 60 s; listeners run on change. */
export class SettingsService {
  private readonly prisma: PrismaClient
  private cached?: { value: CompanySettings, at: number }
  private readonly listeners: Listener[] = []
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  onChange (listener: Listener): void { this.listeners.push(listener) }

  async get (): Promise<CompanySettings> {
    if (this.cached && Date.now() - this.cached.at < CACHE_MS) return this.cached.value
    const value = await this.prisma.companySettings.upsert({ where: { id: 1 }, update: {}, create: { id: 1 } })
    this.cached = { value, at: Date.now() }
    return value
  }

  async update (patch: SettingsPatch, userId: string): Promise<CompanySettings> {
    const current = await this.get()
    const workStart = patch.workStart ?? current.workStart
    const workEnd = patch.workEnd ?? current.workEnd
    if (workEnd <= workStart) throw new AppError(400, 'VALIDATION_FAILED', 'workEnd must be after workStart')
    const value = await this.prisma.companySettings.update({ where: { id: 1 }, data: { ...patch, updatedById: userId } })
    this.cached = { value, at: Date.now() }
    for (const l of this.listeners) await l(value)
    return value
  }
}
