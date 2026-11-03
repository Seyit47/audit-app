'use client'

import { setDisplayTimeZone } from '@/lib/time-zone'

/** Sets the company time zone for the browser before anything below it formats a date. Renders nothing. */
export function TimeZone ({ tz }: { tz: string }) {
  setDisplayTimeZone(tz)
  return null
}
