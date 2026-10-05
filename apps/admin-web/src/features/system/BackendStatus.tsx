'use client';

import { useTranslations } from 'next-intl';
import { StatusBanner } from '@/components/ui/StatusBanner';
import { useBackendStatus } from './useBackendStatus';

export function BackendStatus() {
  const t = useTranslations('status');
  const { status, retry } = useBackendStatus();

  switch (status.state) {
    case 'checking':
      return <StatusBanner variant="info">{t('checking')}</StatusBanner>;
    case 'connected':
      return (
        <StatusBanner variant="success">
          {t('connected', { version: status.serverVersion })}
        </StatusBanner>
      );
    case 'updateRequired':
      return <StatusBanner variant="error">{t('updateRequired')}</StatusBanner>;
    case 'unreachable':
      return (
        <StatusBanner variant="error" action={{ label: t('retry'), onClick: retry }}>
          {t('unreachable')}
        </StatusBanner>
      );
  }
}
