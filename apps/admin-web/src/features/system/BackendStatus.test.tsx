import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { HttpError } from '@/lib/http';
import { renderWithIntl } from '../../../tests/render';
import { getVersion } from './api';
import { BackendStatus } from './BackendStatus';

vi.mock('./api', () => ({ getVersion: vi.fn() }));
vi.mock('@/lib/env', () => ({ APP_VERSION: '0.1.0' }));

const versionInfo = (minAdminWebVersion = '0.1.0') => ({
  serverVersion: '1.2.3',
  minMobileVersion: '0.1.0',
  minAdminWebVersion,
  environment: 'development' as const,
});

describe('BackendStatus', () => {
  beforeEach(() => vi.mocked(getVersion).mockReset());

  it('shows checking while the request is in flight', async () => {
    let resolve: (info: ReturnType<typeof versionInfo>) => void = () => {};
    vi.mocked(getVersion).mockReturnValue(new Promise((r) => (resolve = r)));
    renderWithIntl(<BackendStatus />);
    expect(screen.getByText('Подключение к серверу...')).toBeInTheDocument();
    resolve(versionInfo());
    await screen.findByText('Сервер подключён · v1.2.3');
  });

  it('shows the server version when connected', async () => {
    vi.mocked(getVersion).mockResolvedValue(versionInfo());
    renderWithIntl(<BackendStatus />);
    expect(await screen.findByText('Сервер подключён · v1.2.3')).toBeInTheDocument();
  });

  it('asks for an update when this build is below the minimum version', async () => {
    vi.mocked(getVersion).mockResolvedValue(versionInfo('9.0.0'));
    renderWithIntl(<BackendStatus />);
    expect(await screen.findByText(/Требуется обновление/)).toBeInTheDocument();
  });

  it('shows unreachable with a retry that checks again', async () => {
    vi.mocked(getVersion)
      .mockRejectedValueOnce(new HttpError(null, 'NETWORK_ERROR'))
      .mockResolvedValueOnce(versionInfo());
    renderWithIntl(<BackendStatus />);
    await userEvent.click(await screen.findByRole('button', { name: 'Повторить' }));
    await waitFor(() => expect(screen.getByText('Сервер подключён · v1.2.3')).toBeInTheDocument());
    expect(getVersion).toHaveBeenCalledTimes(2);
  });
});
