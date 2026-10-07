import type { FastifyInstance } from 'fastify'

export const ROUTES_DAILY = 'routes-daily'
export const ROUTES_END_OF_DAY = 'routes-end-of-day'
export const ROUTES_REORDER = 'routes-reorder'

const cron = (hhmm: string) => { const [h, m] = hhmm.split(':'); return `${Number(m)} ${Number(h)} * * *` }

/** Daily routes at workStart and misses at workEnd (company time zone); re-scheduled when settings change. */
export async function registerRouteWorkers (app: FastifyInstance): Promise<void> {
  const routes = app.services.routes
  await app.jobs.work(ROUTES_DAILY, async () => { await routes.generateAll() })
  await app.jobs.work(ROUTES_END_OF_DAY, async () => { await routes.endOfDay() })
  await app.jobs.work<{ stopId: string }>(ROUTES_REORDER, async ({ stopId }) => routes.reorderAfter(stopId))

  const schedule = async () => {
    const s = await app.services.settings.get()
    await app.jobs.schedule(ROUTES_DAILY, cron(s.workStart), null, s.timezone)
    await app.jobs.schedule(ROUTES_END_OF_DAY, cron(s.workEnd), null, s.timezone)
  }
  await schedule()
  app.services.settings.onChange(schedule)
}
