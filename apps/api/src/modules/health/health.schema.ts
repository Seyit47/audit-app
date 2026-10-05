import { type Static, Type } from '@sinclair/typebox';

export const HealthStatusSchema = Type.Object(
  {
    status: Type.Union([Type.Literal('ok'), Type.Literal('degraded')]),
    version: Type.String(),
    uptimeSeconds: Type.Integer({ minimum: 0 }),
    checks: Type.Object({
      database: Type.Union([Type.Literal('ok'), Type.Literal('down')]),
    }),
    timestamp: Type.String({ format: 'date-time' }),
  },
  { $id: 'HealthStatus' },
);

export type HealthStatus = Static<typeof HealthStatusSchema>;
