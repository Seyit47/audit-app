import { describe, expect, it } from 'vitest';
import { loadEnv } from '../../src/config/env.js';

const valid = { DATABASE_URL: 'postgresql://u:p@localhost:5432/db' };

describe('loadEnv', () => {
  it('names DATABASE_URL when it is missing', () => {
    expect(() => loadEnv({})).toThrow(/DATABASE_URL/);
  });

  it('rejects a MIN_MOBILE_VERSION that is not semver', () => {
    expect(() => loadEnv({ ...valid, MIN_MOBILE_VERSION: 'latest' })).toThrow(/MIN_MOBILE_VERSION/);
  });

  it('rejects an unknown APP_ENV', () => {
    expect(() => loadEnv({ ...valid, APP_ENV: 'qa' })).toThrow(/APP_ENV/);
  });

  it('applies defaults', () => {
    expect(loadEnv(valid)).toEqual({
      DATABASE_URL: valid.DATABASE_URL,
      PORT: 3000,
      APP_ENV: 'development',
      LOG_LEVEL: 'info',
      MIN_MOBILE_VERSION: '0.1.0',
      MIN_ADMIN_WEB_VERSION: '0.1.0',
      CORS_ORIGINS: ['http://localhost:3001'],
    });
  });

  it('splits CORS_ORIGINS on commas', () => {
    const env = loadEnv({ ...valid, CORS_ORIGINS: 'https://a.example, https://b.example' });
    expect(env.CORS_ORIGINS).toEqual(['https://a.example', 'https://b.example']);
  });

  it('parses provided values', () => {
    const env = loadEnv({ ...valid, PORT: '4000', APP_ENV: 'staging', MIN_MOBILE_VERSION: '1.2.3' });
    expect(env.PORT).toBe(4000);
    expect(env.APP_ENV).toBe('staging');
    expect(env.MIN_MOBILE_VERSION).toBe('1.2.3');
  });
});
