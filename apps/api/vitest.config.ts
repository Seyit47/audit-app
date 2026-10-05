import { loadEnvFile } from 'node:process';
import { existsSync } from 'node:fs';
import { defineConfig } from 'vitest/config';

// Local runs read DATABASE_URL_TEST from the repo .env; CI sets it directly.
if (existsSync('../../.env')) loadEnvFile('../../.env');

export default defineConfig({
  test: {
    include: ['test/**/*.test.ts'],
    // Integration tests share one database.
    fileParallelism: false,
    testTimeout: 15_000,
  },
});
