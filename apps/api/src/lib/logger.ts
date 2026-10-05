import { randomUUID } from 'node:crypto';
import type { IncomingMessage } from 'node:http';
import type { FastifyServerOptions } from 'fastify';
import type { Env } from '../config/env.js';

const MAX_REQUEST_ID_LENGTH = 128;

/** Reuses a caller-supplied `X-Request-Id` when it is reasonable, otherwise generates one. */
export function requestIdFor(req: IncomingMessage): string {
  const incoming = req.headers['x-request-id'];
  return typeof incoming === 'string' && incoming.length > 0 && incoming.length <= MAX_REQUEST_ID_LENGTH
    ? incoming
    : randomUUID();
}

export function loggerOptions(level: Env['LOG_LEVEL']): FastifyServerOptions['logger'] {
  return {
    level,
    redact: ['req.headers.authorization', 'req.headers.cookie'],
  };
}
