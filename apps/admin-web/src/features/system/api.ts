import { getJson } from '@/lib/http';

export interface VersionInfo {
  serverVersion: string;
  minMobileVersion: string;
  minAdminWebVersion: string;
  environment: 'development' | 'staging' | 'production';
}

export const getVersion = () => getJson<VersionInfo>('/v1/version');
