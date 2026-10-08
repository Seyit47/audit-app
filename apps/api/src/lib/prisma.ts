import { PrismaPg } from '@prisma/adapter-pg'
import { PrismaClient } from '../generated/prisma/client.js'

/** `max`: connections in the pool (pg's default is 10). */
export function createPrisma (databaseUrl: string, max = 10): PrismaClient {
  return new PrismaClient({ adapter: new PrismaPg({ connectionString: databaseUrl, max }) })
}

export type { PrismaClient }
