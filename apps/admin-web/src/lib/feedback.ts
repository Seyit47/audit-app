'use client'

import { pageLocale } from '@/lib/i18n'
// App-wide feedback events: the top progress bar and the snackbar listen for them.
export type ToastTone = 'info' | 'success' | 'error'

export function toast (message: string, tone: ToastTone = 'success') {
  window.dispatchEvent(new CustomEvent('app:toast', { detail: { message, tone } }))
}

/** Shows the progress bar until the URL changes (or a safety timeout). */
export function navigationStarted () {
  window.dispatchEvent(new Event('app:navigate'))
}

/** Shows the progress bar while [work] runs (server actions, refreshes). */
export async function busy<T> (work: Promise<T>): Promise<T> {
  window.dispatchEvent(new Event('app:busy-start'))
  try {
    return await work
  } finally {
    window.dispatchEvent(new Event('app:busy-end'))
  }
}

const messages = {
  en: { saved: 'Changes saved', created: 'Created', deleted: 'Deleted', assigned: 'Salesman assigned', uploaded: 'Photos uploaded', status: 'Status updated', passwordChanged: 'Password changed', exportFailed: 'The export failed. Try again.', failed: 'Something went wrong. Try again.' },
  ru: { saved: 'Изменения сохранены', created: 'Создано', deleted: 'Удалено', assigned: 'Агент назначен', uploaded: 'Фото загружены', status: 'Статус обновлён', passwordChanged: 'Пароль изменён', exportFailed: 'Не удалось сформировать файл. Попробуйте ещё раз.', failed: 'Не удалось выполнить действие. Попробуйте ещё раз.' },
  tk: { saved: 'Üýtgeşmeler ýatda saklandy', created: 'Döredildi', deleted: 'Pozuldy', assigned: 'Agent bellenildi', uploaded: 'Suratlar ýüklendi', status: 'Ýagdaý täzelendi', passwordChanged: 'Açar söz üýtgedildi', exportFailed: 'Faýly taýýarlap bolmady. Gaýtadan synanyşyň.', failed: 'Hereketi ýerine ýetirip bolmady. Gaýtadan synanyşyň.' }
}

/** Snackbar text in the page language (`<html lang>`). */
export function say (key: keyof typeof messages.en, tone: ToastTone = 'success') {
  const lang = pageLocale()
  toast(messages[lang][key], tone)
}

/** Runs client work (server actions, loads); a failure becomes an error snackbar instead of an error page. */
export async function guard (work: () => Promise<unknown>, onError?: () => void) {
  try {
    await work()
  } catch (err) {
    console.error(err)
    onError?.()
    say('failed', 'error')
  }
}
