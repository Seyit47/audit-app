import { Bell, CircleHelp, Search, User } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { BackendStatus } from '@/features/system/BackendStatus';
import { LocaleSwitcher } from './LocaleSwitcher';

export function Topbar() {
  const t = useTranslations('topbar');
  const iconButton = 'rounded-full p-2 text-text-muted hover:bg-accent-soft';

  return (
    <header className="flex h-16 items-center gap-4 border-b border-border bg-surface px-6">
      <label className="flex w-full max-w-md items-center gap-2 rounded-lg bg-accent-soft px-3 py-2">
        <Search className="size-4 text-text-muted" aria-hidden />
        <input
          type="search"
          placeholder={t('search')}
          aria-label={t('search')}
          className="w-full bg-transparent text-sm outline-none"
        />
      </label>
      <div className="ml-auto flex items-center gap-2">
        <BackendStatus />
        <LocaleSwitcher />
        <button type="button" className={iconButton} aria-label={t('notifications')}>
          <Bell className="size-5" aria-hidden />
        </button>
        <button type="button" className={iconButton} aria-label={t('help')}>
          <CircleHelp className="size-5" aria-hidden />
        </button>
        <button
          type="button"
          className="rounded-full bg-accent p-2 text-on-accent"
          aria-label={t('profile')}
        >
          <User className="size-5" aria-hidden />
        </button>
      </div>
    </header>
  );
}
