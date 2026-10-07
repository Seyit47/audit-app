import { defineCopy } from '@/lib/i18n'

// English from Figma 3:407 (sidebar 3:408, header 3:853); Russian sidebar from the Map frames (21:2).
export const layoutCopy = defineCopy({
  en: {
    companyFallback: 'COMPANY NAME',
    nav: { map: 'Map', shops: 'Shops', products: 'Products', salesmen: 'Salesmen', pictures: 'Pictures', settings: 'Settings' },
    searchPlaceholder: 'Search clients...',
    notifications: 'Notifications',
    help: 'Help & Resources',
    account: 'Account',
    language: 'Language',
    signOut: 'Sign out'
  },
  ru: {
    companyFallback: 'COMPANY NAME',
    nav: { map: 'Карта', shops: 'Клиенты', products: 'Продукции', salesmen: 'Агенты', pictures: 'Галерея', settings: 'Настройки' },
    searchPlaceholder: 'Поиск клиентов...',
    notifications: 'Уведомления',
    help: 'Помощь',
    account: 'Аккаунт',
    language: 'Язык',
    signOut: 'Выйти'
  }
})

export type LayoutCopy = typeof layoutCopy.en
