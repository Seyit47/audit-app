import type { routing } from '@/i18n/routing';
import type messages from '../messages/ru.json';

// Type-checks translation keys against the Russian (default) messages.
declare module 'next-intl' {
  interface AppConfig {
    Locale: (typeof routing.locales)[number];
    Messages: typeof messages;
  }
}
