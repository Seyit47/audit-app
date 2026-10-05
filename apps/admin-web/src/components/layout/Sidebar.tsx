'use client';

import { Crosshair } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { Link, usePathname } from '@/i18n/navigation';
import { NAV_ITEMS } from './nav-items';

export function Sidebar() {
  const t = useTranslations();
  const pathname = usePathname();

  return (
    <aside className="flex w-[230px] shrink-0 flex-col bg-accent text-on-accent">
      <div className="flex h-16 items-center gap-2 px-4">
        <Crosshair className="size-6" aria-hidden />
        <span className="text-lg font-bold uppercase">{t('app.companyName')}</span>
      </div>
      <nav aria-label={t('nav.label')} className="mt-4 flex flex-col gap-1 pr-2">
        {NAV_ITEMS.map(({ key, href, icon: Icon }) => {
          const active = href === '/' ? pathname === '/' : pathname.startsWith(href);
          return (
            <Link
              key={key}
              href={href}
              aria-current={active ? 'page' : undefined}
              className={`flex items-center gap-3 rounded-r-xl px-4 py-3 transition-colors ${
                active ? 'bg-surface text-accent' : 'hover:bg-on-accent/10'
              }`}
            >
              <Icon className="size-5" aria-hidden />
              {t(`nav.${key}`)}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
