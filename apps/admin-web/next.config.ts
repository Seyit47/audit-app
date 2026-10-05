import type { NextConfig } from 'next';
import createNextIntlPlugin from 'next-intl/plugin';

const withNextIntl = createNextIntlPlugin();

const nextConfig: NextConfig = {
  env: { NEXT_PUBLIC_APP_VERSION: process.env.npm_package_version },
};

export default withNextIntl(nextConfig);
