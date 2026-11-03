import { afterEach, describe, expect, it } from 'vitest'
import { daysBetween, isoDay, isToday, setDisplayTimeZone, shiftDay, startOfDay, weekdayOf } from './time-zone'
import { formatDate } from './i18n'
import { lastActivity } from './format'

describe('company time zone', () => {
  afterEach(() => setDisplayTimeZone('Asia/Ashgabat'))

  it('days and "today" follow the company zone, not the machine', () => {
    // 21:30 UTC on the 6th is already the 7th in Ashgabat (UTC+5).
    const at = new Date('2026-10-06T21:30:00Z')
    expect(isoDay(at)).toBe('2026-10-07')
    expect(isToday(at, new Date('2026-10-07T03:00:00Z'))).toBe(true)
    expect(isToday(at, new Date('2026-10-06T18:00:00Z'))).toBe(false)
    expect(daysBetween(new Date('2026-10-06T21:30:00Z'), new Date('2026-10-08T01:00:00Z'))).toBe(1)
    expect(startOfDay('2026-10-07').toISOString()).toBe('2026-10-06T19:00:00.000Z')
    expect(shiftDay('2026-03-01', -1)).toBe('2026-02-28')
    expect(weekdayOf('2026-10-05')).toBe(0) // a Monday
  })

  it('times are formatted in the company zone on any machine', () => {
    expect(formatDate('ru', { hour: '2-digit', minute: '2-digit', hour12: false }, '2026-10-06T21:30:00Z')).toBe('02:30')
    expect(formatDate('tk', { day: 'numeric', month: 'short' }, '2026-10-31T20:30:00Z')).toBe('1 noý')
    setDisplayTimeZone('UTC')
    expect(formatDate('ru', { hour: '2-digit', minute: '2-digit', hour12: false }, '2026-10-06T21:30:00Z')).toBe('21:30')
  })

  it('last activity says "Today" / "Yesterday" by company days', () => {
    const now = new Date('2026-10-07T04:00:00Z') // 09:00 in Ashgabat
    expect(lastActivity('2026-10-06T21:30:00Z', 'en', now)).toBe('Today, 02:30')
    expect(lastActivity('2026-10-06T18:30:00Z', 'en', now)).toBe('Yesterday, 23:30')
  })
})
