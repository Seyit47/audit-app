export interface ApiErrorBody { error: { code: string, message: string, details?: unknown }, requestId?: string }

/** An API error with the server's machine-readable code. */
export class ApiError extends Error {
  readonly status: number
  readonly code: string
  readonly details?: unknown

  constructor (status: number, code: string, message: string, details?: unknown) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.code = code
    this.details = details
  }

  static from (status: number, body: ApiErrorBody | null): ApiError {
    return new ApiError(status, body?.error?.code ?? 'INTERNAL_ERROR', body?.error?.message ?? 'Request failed', body?.error?.details)
  }
}
