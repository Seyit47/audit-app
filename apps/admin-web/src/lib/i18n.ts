// Admin web languages (constitution: Localization; spec gap A12). Russian is the default; Turkmen (Latin script).
export const LOCALES = ['ru', 'en', 'tk'] as const
export type Locale = typeof LOCALES[number]
export const DEFAULT_LOCALE: Locale = 'ru'
export const LOCALE_COOKIE = 'lang'

export const isLocale = (value: unknown): value is Locale => LOCALES.includes(value as Locale)

/** A feature's strings in every language; the type keeps the Russian and Turkmen keys in step with the English. */
export function defineCopy<T> (copy: { en: T, ru: NoInfer<T>, tk: NoInfer<T> }) {
  return copy
}

/**
 * BCP 47 tag for Intl. Browsers ship without Turkmen locale data (Node has it), so Turkmen uses Russian, which
 * shares its number grouping, day–month order and 24-hour clock; server and client then render the same text.
 * Format dates with `formatDate`, which also puts in the Turkmen month names.
 */
export const intlTag = (locale: Locale) => ({ ru: 'ru-RU', en: 'en-US', tk: 'ru-RU' } as const)[locale]

const TK_MONTHS = {
  short: ['ýan', 'few', 'mar', 'apr', 'maý', 'iýun', 'iýul', 'awg', 'sen', 'okt', 'noý', 'dek'],
  long: ['ýanwar', 'fewral', 'mart', 'aprel', 'maý', 'iýun', 'iýul', 'awgust', 'sentýabr', 'oktýabr', 'noýabr', 'dekabr']
}

/** `Intl.DateTimeFormat(locale, options).format(date)` that also works for Turkmen ("7 okt 2026, 18:44"). */
export function formatDate (locale: Locale, options: Intl.DateTimeFormatOptions, date: Date | string): string {
  const d = new Date(date)
  const format = new Intl.DateTimeFormat(intlTag(locale), options)
  if (locale !== 'tk') return format.format(d)
  const month = options.month === 'short' || options.month === 'long' ? TK_MONTHS[options.month] : null
  return format.formatToParts(d).map((part) => {
    if (part.type === 'month' && month != null) return month[d.getMonth()]
    if (part.type === 'literal') return part.value.replace(/\s?г\./, '')
    return part.value
  }).join('')
}

/** One string per language, for the few texts that live outside a copy file. */
export const pick = <T>(locale: Locale, texts: Record<Locale, T>): T => texts[locale]

/** The page language on the client (`<html lang>`). */
export const pageLocale = (): Locale => {
  const lang = typeof document === 'undefined' ? DEFAULT_LOCALE : document.documentElement.lang
  return isLocale(lang) ? lang : DEFAULT_LOCALE
}

/**
 * Picks the form for `n`: Russian takes [one, few, many] ("1 точка", "2 точки", "5 точек"), English [one, other];
 * Turkmen nouns stay singular after a number ("5 nokat"), so it uses the first form.
 */
export function plural (locale: Locale, n: number, forms: readonly string[]): string {
  if (locale === 'tk') return forms[0]
  const rule = new Intl.PluralRules(locale).select(n)
  if (locale === 'ru') return forms[rule === 'one' ? 0 : rule === 'few' ? 1 : 2] ?? forms[0]
  return forms[rule === 'one' ? 0 : 1] ?? forms[0]
}

/** Fills the `{n}` placeholder of a copy string. */
export const sub = (s: string, n: number | string) => s.replace('{n}', String(n))
