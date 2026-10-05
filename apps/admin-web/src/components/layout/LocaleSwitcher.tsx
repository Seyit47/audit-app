'use client';

import { useLocale, useTranslations } from 'next-intl';
import { usePathname, useRouter } from '@/i18n/navigation';
import { routing } from '@/i18n/routing';

export function LocaleSwitcher() {
  const t = useTranslations('locale');
  const activeLocale = useLocale();
  const router = useRouter();
  const pathname = usePathname();

  return (
    <div role="group" aria-label={t('label')} className="flex rounded-lg bg-accent-soft p-0.5 text-xs">
      {routing.locales.map((locale) => (
        <button
          key={locale}
          type="button"
          aria-pressed={locale === activeLocale}
          onClick={() => router.replace(pathname, { locale })}
          className={`rounded-md px-2 py-1 font-medium ${
            locale === activeLocale ? 'bg-surface text-accent' : 'text-text-muted'
          }`}
        >
          {t(locale)}
        </button>
      ))}
    </div>
  );
}
