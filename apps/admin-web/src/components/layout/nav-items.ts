import {
  Camera,
  LayoutGrid,
  Map,
  Package,
  Settings,
  Store,
  Users,
  type LucideIcon,
} from 'lucide-react';

export type NavKey = 'dashboard' | 'map' | 'shops' | 'products' | 'salesmen' | 'pictures' | 'settings';

export interface NavItem {
  key: NavKey;
  href: string;
  icon: LucideIcon;
}

/** Admin sections in sidebar order. Pages and the sidebar both read from here. */
export const NAV_ITEMS: readonly NavItem[] = [
  { key: 'dashboard', href: '/', icon: LayoutGrid },
  { key: 'map', href: '/map', icon: Map },
  { key: 'shops', href: '/shops', icon: Store },
  { key: 'products', href: '/products', icon: Package },
  { key: 'salesmen', href: '/salesmen', icon: Users },
  { key: 'pictures', href: '/pictures', icon: Camera },
  { key: 'settings', href: '/settings', icon: Settings },
];

export const navItem = (key: NavKey): NavItem => NAV_ITEMS.find((item) => item.key === key)!;
