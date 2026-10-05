'use client';

import { useCallback, useEffect, useState } from 'react';
import { APP_VERSION } from '@/lib/env';
import { isVersionLower } from '@/lib/version';
import { getVersion, type VersionInfo } from './api';

export type BackendStatus =
  | { state: 'checking' }
  | { state: 'connected'; serverVersion: string }
  | { state: 'updateRequired' }
  | { state: 'unreachable' };

const statusFor = (info: VersionInfo): BackendStatus =>
  isVersionLower(APP_VERSION, info.minAdminWebVersion)
    ? { state: 'updateRequired' }
    : { state: 'connected', serverVersion: info.serverVersion };

/** Checks that the API is reachable and that this build is still supported. */
export function useBackendStatus() {
  const [status, setStatus] = useState<BackendStatus>({ state: 'checking' });
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    let cancelled = false;
    getVersion().then(
      (info) => !cancelled && setStatus(statusFor(info)),
      () => !cancelled && setStatus({ state: 'unreachable' }),
    );
    return () => {
      cancelled = true;
    };
  }, [attempt]);

  const retry = useCallback(() => {
    setStatus({ state: 'checking' });
    setAttempt((n) => n + 1);
  }, []);

  return { status, retry };
}
