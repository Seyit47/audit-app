import type { Env } from '../../config/env.js';
import type { VersionInfo } from './version.schema.js';

export class VersionService {
  constructor(
    private readonly env: Env,
    private readonly serverVersion: string,
  ) {}

  getVersionInfo(): VersionInfo {
    return {
      serverVersion: this.serverVersion,
      minMobileVersion: this.env.MIN_MOBILE_VERSION,
      minAdminWebVersion: this.env.MIN_ADMIN_WEB_VERSION,
      environment: this.env.APP_ENV,
    };
  }
}
