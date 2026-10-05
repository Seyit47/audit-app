import { apiBaseUrl } from './env';

/** A failed API call. `code` comes from the API error body, or `NETWORK_ERROR`. */
export class HttpError extends Error {
  constructor(
    readonly status: number | null,
    readonly code: string,
  ) {
    super(`API request failed: ${code}`);
    this.name = 'HttpError';
  }
}

/** GETs JSON from the API, mapping every failure to an {@link HttpError}. */
export async function getJson<T>(path: string): Promise<T> {
  let response: Response;
  try {
    response = await fetch(`${apiBaseUrl()}${path}`, {
      headers: { 'X-Client-Name': 'admin-web' },
      cache: 'no-store',
    });
  } catch {
    throw new HttpError(null, 'NETWORK_ERROR');
  }

  const body: unknown = await response.json().catch(() => null);
  if (!response.ok) {
    const code =
      (body as { error?: { code?: string } } | null)?.error?.code ?? `HTTP_${response.status}`;
    throw new HttpError(response.status, code);
  }
  return body as T;
}
