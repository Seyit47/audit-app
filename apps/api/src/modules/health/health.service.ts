import type { HealthRepository } from './health.repository.js';
import type { HealthStatus } from './health.schema.js';

export class HealthService {
  constructor(
    private readonly repository: HealthRepository,
    private readonly version: string,
  ) {}

  async check(): Promise<HealthStatus> {
    const databaseUp = await this.repository.isDatabaseUp();
    return {
      status: databaseUp ? 'ok' : 'degraded',
      version: this.version,
      uptimeSeconds: Math.floor(process.uptime()),
      checks: { database: databaseUp ? 'ok' : 'down' },
      timestamp: new Date().toISOString(),
    };
  }
}
