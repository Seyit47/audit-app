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

/** Picks the form for `n`: Russian takes [one, few, many] ("1 точка", "2 точки", "5 точек"), English [one, other]. */
export function plural (locale: Locale, n: number, forms: readonly string[]): string {
  const rule = new Intl.PluralRules(locale).select(n)
  if (locale === 'ru') return forms[rule === 'one' ? 0 : rule === 'few' ? 1 : 2] ?? forms[0]
  return forms[rule === 'one' ? 0 : 1] ?? forms[0]
}

/** Fills the `{n}` placeholder of a copy string. */
export const sub = (s: string, n: number | string) => s.replace('{n}', String(n))
