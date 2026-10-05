import { defineConfig } from 'prisma/config';

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: { path: 'prisma/migrations' },
  // Not needed by `prisma generate`; required by migrate commands.
  datasource: { url: process.env.DATABASE_URL ?? '' },
});
