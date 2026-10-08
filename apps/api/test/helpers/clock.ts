import { localMinutes } from '../../src/lib/time.js'

const RealDate = Date

/**
 * Runs the clock as if it were `hour`:00 today in `timezone`, still ticking. Tests that place events
 * "N minutes ago" then stay inside one local day and inside working hours whenever they run (near
 * midnight they used to straddle two days). The server reads time only from Date, so this covers it too.
 * Returns the function that restores the real clock.
 */
export function clockAt (hour: number, timezone: string): () => void {
  const offset = (hour * 60 - localMinutes(new RealDate(), timezone)) * 60_000
  class ShiftedDate extends RealDate {
    constructor (...args: ConstructorParameters<typeof Date> | []) {
      if (args.length === 0) super(RealDate.now() + offset)
      else super(...(args as ConstructorParameters<typeof Date>))
    }

    static override now (): number { return RealDate.now() + offset }
  }
  globalThis.Date = ShiftedDate as DateConstructor
  return () => { globalThis.Date = RealDate }
}
