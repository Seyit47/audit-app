import { afterEach, describe, expect, it } from 'vitest';
import type { App } from '../../src/app.js';
import { buildTestApp, UNREACHABLE_DATABASE_URL } from '../helpers/app.js';

let app: App | undefined;

afterEach(async () => {
  await app?.close();
  app = undefined;
});

describe('CORS', () => {
  it('allows the configured admin web origin', async () => {
    app = await buildTestApp({
      DATABASE_URL: UNREACHABLE_DATABASE_URL,
      CORS_ORIGINS: ['http://localhost:3001'],
    });
    const res = await app.inject({ url: '/v1/version', headers: { origin: 'http://localhost:3001' } });
    expect(res.headers['access-control-allow-origin']).toBe('http://localhost:3001');
  });

  it('does not allow other origins', async () => {
    app = await buildTestApp({
      DATABASE_URL: UNREACHABLE_DATABASE_URL,
      CORS_ORIGINS: ['http://localhost:3001'],
    });
    const res = await app.inject({ url: '/v1/version', headers: { origin: 'https://evil.example' } });
    expect(res.headers['access-control-allow-origin']).toBeUndefined();
  });
});
