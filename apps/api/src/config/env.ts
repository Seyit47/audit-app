import { z } from 'zod';

const semver = z.string().regex(/^\d+\.\d+\.\d+$/, 'must be a semantic version like 1.2.3');

const envSchema = z.object({
  DATABASE_URL: z.string().min(1),
  PORT: z.coerce.number().int().positive().default(3000),
  APP_ENV: z.enum(['development', 'staging', 'production']).default('development'),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent']).default('info'),
  MIN_MOBILE_VERSION: semver.default('0.1.0'),
  MIN_ADMIN_WEB_VERSION: semver.default('0.1.0'),
  // Comma-separated browser origins allowed to call the API (the admin web).
  CORS_ORIGINS: z
    .string()
    .default('http://localhost:3001')
    .transform((value) => value.split(',').map((origin) => origin.trim()).filter(Boolean)),
});

export type Env = z.infer<typeof envSchema>;

/** Validates environment variables, failing with every invalid variable named. */
export function loadEnv(source: Record<string, string | undefined> = process.env): Env {
  const result = envSchema.safeParse(source);
  if (!result.success) {
    const problems = result.error.issues
      .map((issue) => `  ${issue.path.join('.')}: ${issue.message}`)
      .join('\n');
    throw new Error(`Invalid environment configuration:\n${problems}`);
  }
  return result.data;
}
