import Fastify from 'fastify';
import { describe, expect, it } from 'vitest';
import { AppError } from '../../src/errors/app-error.js';
import { registerErrorHandling } from '../../src/errors/error-handler.js';

async function buildTestServer() {
  const app = Fastify();
  registerErrorHandling(app);
  app.get(
    '/validated',
    {
      schema: {
        querystring: {
          type: 'object',
          required: ['page'],
          properties: { page: { type: 'integer' } },
        },
      },
    },
    async () => ({ ok: true }),
  );
  app.get('/conflict', async () => {
    throw new AppError(409, 'CONFLICT', 'Already exists');
  });
  app.get('/crash', async () => {
    throw new Error('db password is hunter2');
  });
  await app.ready();
  return app;
}

describe('error handling', () => {
  it('returns 404 NOT_FOUND for unknown routes', async () => {
    const app = await buildTestServer();
    const res = await app.inject({ url: '/missing' });
    expect(res.statusCode).toBe(404);
    expect(res.json()).toEqual({
      error: { code: 'NOT_FOUND', message: expect.any(String) },
      requestId: expect.any(String),
    });
  });

  it('returns 400 VALIDATION_FAILED with field details', async () => {
    const app = await buildTestServer();
    const res = await app.inject({ url: '/validated?page=abc' });
    expect(res.statusCode).toBe(400);
    const body = res.json();
    expect(body.error.code).toBe('VALIDATION_FAILED');
    expect(body.error.details).toEqual(
      expect.arrayContaining([expect.objectContaining({ field: expect.any(String) })]),
    );
  });

  it('passes AppError status and code through', async () => {
    const app = await buildTestServer();
    const res = await app.inject({ url: '/conflict' });
    expect(res.statusCode).toBe(409);
    expect(res.json().error).toEqual({ code: 'CONFLICT', message: 'Already exists' });
  });

  it('hides unexpected errors behind 500 INTERNAL_ERROR', async () => {
    const app = await buildTestServer();
    const res = await app.inject({ url: '/crash' });
    expect(res.statusCode).toBe(500);
    expect(res.json().error.code).toBe('INTERNAL_ERROR');
    expect(res.body).not.toContain('hunter2');
  });
});
