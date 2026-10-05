/** An expected failure that maps directly to an HTTP error response. */
export class AppError extends Error {
  constructor(
    readonly statusCode: number,
    readonly code: string,
    message: string,
    readonly details?: unknown[],
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export interface ApiErrorBody {
  error: { code: string; message: string; details?: unknown[] };
  requestId: string;
}
