import { useTranslations } from 'next-intl';
import { EmptyState } from '@/components/ui/EmptyState';
import { PageHeader } from '@/components/ui/PageHeader';
import { type NavKey, navItem } from './nav-items';

/** Placeholder content for an admin section that has no features yet. */
export function SectionPlaceholder({ section }: { section: NavKey }) {
  const t = useTranslations();
  return (
    <>
      <PageHeader title={t(`nav.${section}`)} />
      <EmptyState icon={navItem(section).icon} message={t('common.comingSoon')} />
    </>
  );
}
