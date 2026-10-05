import { render } from '@testing-library/react';
import { NextIntlClientProvider } from 'next-intl';
import type { ReactElement } from 'react';
import en from '../messages/en.json';
import ru from '../messages/ru.json';

const messages = { ru, en };

/** Renders [ui] with translations, Russian by default like the app. */
export function renderWithIntl(ui: ReactElement, locale: 'ru' | 'en' = 'ru') {
  return render(
    <NextIntlClientProvider locale={locale} messages={messages[locale]}>
      {ui}
    </NextIntlClientProvider>,
  );
}
