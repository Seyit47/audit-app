import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { renderWithIntl } from '../../../tests/render';
import { LocaleSwitcher } from './LocaleSwitcher';

const replace = vi.fn();
vi.mock('@/i18n/navigation', () => ({
  usePathname: () => '/shops',
  useRouter: () => ({ replace }),
}));

describe('LocaleSwitcher', () => {
  it('switches to English on the same page', async () => {
    renderWithIntl(<LocaleSwitcher />);
    expect(screen.getByRole('button', { name: 'RU' })).toHaveAttribute('aria-pressed', 'true');
    await userEvent.click(screen.getByRole('button', { name: 'EN' }));
    expect(replace).toHaveBeenCalledWith('/shops', { locale: 'en' });
  });
});
