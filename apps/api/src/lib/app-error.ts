export type ErrorCode =
  | 'VALIDATION_FAILED' | 'UNAUTHENTICATED' | 'FORBIDDEN' | 'DEVICE_NOT_BOUND' | 'NOT_FOUND'
  | 'CONFLICT' | 'SHOP_NOT_ACTIVE' | 'GEOFENCE' | 'GPS_ACCURACY' | 'RATE_LIMITED' | 'METHOD_NOT_ALLOWED' | 'INTERNAL_ERROR'

/** An expected failure that maps to an HTTP error with a stable machine-readable code. */
export class AppError extends Error {
  readonly statusCode: number
  readonly code: ErrorCode
  readonly details?: unknown

  constructor (statusCode: number, code: ErrorCode, message: string, details?: unknown) {
    super(message)
    this.name = 'AppError'
    this.statusCode = statusCode
    this.code = code
    this.details = details
  }
}

export const notFound = (what = 'Resource'): AppError => new AppError(404, 'NOT_FOUND', `${what} not found`)
export const conflict = (message: string): AppError => new AppError(409, 'CONFLICT', message)
export const forbidden = (message = 'Forbidden'): AppError => new AppError(403, 'FORBIDDEN', message)
