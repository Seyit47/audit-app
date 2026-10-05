import { buildApp } from './app.js';
import { loadEnv } from './config/env.js';
import { createPrismaClient } from './lib/prisma.js';

let env;
try {
  env = loadEnv();
} catch (error) {
  console.error((error as Error).message);
  process.exit(1);
}

const prisma = createPrismaClient(env.DATABASE_URL);
const app = await buildApp({ env, prisma });

app.addHook('onClose', async () => {
  await prisma.$disconnect();
});

for (const signal of ['SIGINT', 'SIGTERM'] as const) {
  process.once(signal, () => void app.close());
}

await app.listen({ port: env.PORT, host: '0.0.0.0' });
