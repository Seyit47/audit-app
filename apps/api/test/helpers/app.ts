import { buildApp } from '../../src/app.js';
import { type Env, loadEnv } from '../../src/config/env.js';
import { createPrismaClient } from '../../src/lib/prisma.js';

/** A database URL nothing listens on, for "database down" scenarios. */
export const UNREACHABLE_DATABASE_URL = 'postgresql://audit:x@127.0.0.1:1/none';

export function testDatabaseUrl(): string {
  const url = process.env.DATABASE_URL_TEST;
  if (!url) {
    throw new Error('DATABASE_URL_TEST is not set; integration tests need a real PostgreSQL database.');
  }
  return url;
}

/** Builds the real app against the test database (or an override), with logging silenced. */
export async function buildTestApp(overrides: Partial<Env> = {}) {
  const env: Env = {
    ...loadEnv({ DATABASE_URL: overrides.DATABASE_URL ?? testDatabaseUrl(), LOG_LEVEL: 'silent' }),
    ...overrides,
  };
  const prisma = createPrismaClient(env.DATABASE_URL);
  const app = await buildApp({ env, prisma });
  app.addHook('onClose', async () => {
    await prisma.$disconnect();
  });
  return app;
}
