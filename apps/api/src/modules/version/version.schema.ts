import { type Static, Type } from '@sinclair/typebox';

export const VersionInfoSchema = Type.Object(
  {
    serverVersion: Type.String(),
    minMobileVersion: Type.String(),
    minAdminWebVersion: Type.String(),
    environment: Type.Union([
      Type.Literal('development'),
      Type.Literal('staging'),
      Type.Literal('production'),
    ]),
  },
  { $id: 'VersionInfo' },
);

export type VersionInfo = Static<typeof VersionInfoSchema>;
