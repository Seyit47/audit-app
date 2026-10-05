import { describe, expect, it } from 'vitest';
import type { HealthRepository } from '../../src/modules/health/health.repository.js';
import { HealthService } from '../../src/modules/health/health.service.js';

const fakeRepository = (databaseUp: boolean): HealthRepository => ({
  isDatabaseUp: async () => databaseUp,
});

describe('HealthService', () => {
  it('reports ok when the database is up', async () => {
    const status = await new HealthService(fakeRepository(true), '1.2.3').check();
    expect(status).toMatchObject({ status: 'ok', version: '1.2.3', checks: { database: 'ok' } });
  });

  it('reports degraded when the database is down', async () => {
    const status = await new HealthService(fakeRepository(false), '1.2.3').check();
    expect(status).toMatchObject({ status: 'degraded', checks: { database: 'down' } });
  });

  it('includes uptime and an ISO UTC timestamp', async () => {
    const status = await new HealthService(fakeRepository(true), '1.2.3').check();
    expect(Number.isInteger(status.uptimeSeconds)).toBe(true);
    expect(status.uptimeSeconds).toBeGreaterThanOrEqual(0);
    expect(status.timestamp).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/);
  });
});
