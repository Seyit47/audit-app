import { afterEach, describe, expect, it } from 'vitest';
import type { App } from '../../src/app.js';
import { buildTestApp, UNREACHABLE_DATABASE_URL } from '../helpers/app.js';

let app: App | undefined;

afterEach(async () => {
  await app?.close();
  app = undefined;
});

describe('GET /v1/health', () => {
  it('returns 200 ok against the real test database', async () => {
    app = await buildTestApp();
    const res = await app.inject({ url: '/v1/health' });
    expect(res.statusCode).toBe(200);
    expect(res.headers['x-request-id']).toBeTruthy();
    expect(res.json()).toMatchObject({ status: 'ok', checks: { database: 'ok' } });
  });

  it('returns 503 degraded within 3 s when the database is unreachable', async () => {
    app = await buildTestApp({ DATABASE_URL: UNREACHABLE_DATABASE_URL });
    const started = Date.now();
    const res = await app.inject({ url: '/v1/health' });
    expect(Date.now() - started).toBeLessThan(3000);
    expect(res.statusCode).toBe(503);
    expect(res.json()).toMatchObject({ status: 'degraded', checks: { database: 'down' } });
  });
});
