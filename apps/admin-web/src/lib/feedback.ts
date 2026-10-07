'use client'

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
  en: { saved: 'Changes saved', created: 'Created', deleted: 'Deleted', assigned: 'Salesman assigned', uploaded: 'Photos uploaded', status: 'Status updated', exportFailed: 'The export failed. Try again.' },
  ru: { saved: 'Изменения сохранены', created: 'Создано', deleted: 'Удалено', assigned: 'Агент назначен', uploaded: 'Фото загружены', status: 'Статус обновлён', exportFailed: 'Не удалось сформировать файл. Попробуйте ещё раз.' }
}

/** Snackbar text in the page language (`<html lang>`). */
export function say (key: keyof typeof messages.en, tone: ToastTone = 'success') {
  const lang = document.documentElement.lang === 'en' ? 'en' : 'ru'
  toast(messages[lang][key], tone)
}
