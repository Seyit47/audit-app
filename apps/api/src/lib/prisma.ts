import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../generated/prisma/client.js';

/**
 * Creates the Prisma client. It connects on first query, so the API can start (and report
 * itself unhealthy) while the database is down.
 */
export function createPrismaClient(databaseUrl: string): PrismaClient {
  const adapter = new PrismaPg({ connectionString: databaseUrl, connectionTimeoutMillis: 2000 });
  return new PrismaClient({ adapter });
}

export type { PrismaClient };
