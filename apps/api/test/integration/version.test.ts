import { afterEach, describe, expect, it } from 'vitest';
import type { App } from '../../src/app.js';
import { appVersion } from '../../src/lib/app-version.js';
import { buildTestApp, UNREACHABLE_DATABASE_URL } from '../helpers/app.js';

let app: App | undefined;

afterEach(async () => {
  await app?.close();
  app = undefined;
});

describe('GET /v1/version', () => {
  it('returns exactly the version info from package.json and env', async () => {
    app = await buildTestApp({
      DATABASE_URL: UNREACHABLE_DATABASE_URL,
      APP_ENV: 'staging',
      MIN_MOBILE_VERSION: '1.4.0',
      MIN_ADMIN_WEB_VERSION: '0.2.0',
    });
    const res = await app.inject({ url: '/v1/version' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({
      serverVersion: appVersion,
      minMobileVersion: '1.4.0',
      minAdminWebVersion: '0.2.0',
      environment: 'staging',
    });
  });

  it('returns the standard 404 error for unknown routes', async () => {
    app = await buildTestApp({ DATABASE_URL: UNREACHABLE_DATABASE_URL });
    const res = await app.inject({ url: '/v1/nope' });
    expect(res.statusCode).toBe(404);
    expect(res.json()).toEqual({
      error: { code: 'NOT_FOUND', message: expect.any(String) },
      requestId: res.headers['x-request-id'],
    });
  });
});
