// Admin web languages (constitution: Localization; spec gap A12). Russian is the default.
export const LOCALES = ['ru', 'en'] as const
export type Locale = typeof LOCALES[number]
export const DEFAULT_LOCALE: Locale = 'ru'
export const LOCALE_COOKIE = 'lang'

export const isLocale = (value: unknown): value is Locale => LOCALES.includes(value as Locale)

/** A feature's strings in both languages; the type keeps the Russian keys in step with the English ones. */
export function defineCopy<T> (copy: { en: T, ru: NoInfer<T> }) {
  return copy
}
