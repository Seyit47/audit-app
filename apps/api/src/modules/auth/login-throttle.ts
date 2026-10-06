/** Counts failed logins per key in a sliding window; blocks once the limit is reached. */
export class LoginThrottle {
  private readonly failures = new Map<string, number[]>()
  private readonly limit: number
  private readonly windowMs: number
  constructor (limit = 5, windowMs = 60_000) {
    this.limit = limit
    this.windowMs = windowMs
  }

  private recent (key: string, now: number): number[] {
    const kept = (this.failures.get(key) ?? []).filter((t) => now - t < this.windowMs)
    if (kept.length === 0) this.failures.delete(key)
    else this.failures.set(key, kept)
    return kept
  }

  isBlocked (key: string, now = Date.now()): boolean {
    return this.recent(key, now).length >= this.limit
  }

  fail (key: string, now = Date.now()): void {
    this.failures.set(key, [...this.recent(key, now), now])
  }

  reset (key: string): void {
    this.failures.delete(key)
  }
}
