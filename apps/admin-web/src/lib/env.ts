/** Base URL of the API. Read at call time so a missing value fails with a clear message. */
export function apiBaseUrl(): string {
  const url = process.env.NEXT_PUBLIC_API_BASE_URL;
  if (!url) {
    throw new Error('NEXT_PUBLIC_API_BASE_URL is not set; the admin web cannot reach the API.');
  }
  return url;
}

/** Version of this admin web build. */
export const APP_VERSION = process.env.NEXT_PUBLIC_APP_VERSION ?? '0.0.0';
