import type { FastifyError, FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import { AppError, type ApiErrorBody } from './app-error.js';

function send(
  reply: FastifyReply,
  request: FastifyRequest,
  statusCode: number,
  error: ApiErrorBody['error'],
) {
  const body: ApiErrorBody = { error, requestId: request.id };
  return reply.status(statusCode).send(body);
}

/** Gives every error response the same `{ error: { code, message, details? }, requestId }` shape. */
export function registerErrorHandling(app: FastifyInstance): void {
  app.setNotFoundHandler((request, reply) =>
    send(reply, request, 404, { code: 'NOT_FOUND', message: 'Resource not found' }),
  );

  app.setErrorHandler((error: FastifyError | AppError, request, reply) => {
    if (error instanceof AppError) {
      const { code, message, details } = error;
      return send(reply, request, error.statusCode, details ? { code, message, details } : { code, message });
    }

    if ('validation' in error && error.validation) {
      return send(reply, request, 400, {
        code: 'VALIDATION_FAILED',
        message: 'Request validation failed',
        details: error.validation.map((issue) => ({
          field: issue.instancePath || String(issue.params?.missingProperty ?? ''),
          message: issue.message ?? 'is invalid',
        })),
      });
    }

    request.log.error({ err: error }, 'Unhandled error');
    return send(reply, request, 500, { code: 'INTERNAL_ERROR', message: 'Something went wrong' });
  });
}
