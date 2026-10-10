'use client'

import { pageLocale, DEFAULT_LOCALE } from '@/lib/i18n'
import Link from 'next/link'
import { useSyncExternalStore } from 'react'

const text = {
  en: {
    error: { title: 'Something went wrong', body: 'This section could not be loaded. Your data is safe — try again in a moment.' },
    notFound: { title: 'Nothing here', body: 'This page or record does not exist, or it was deleted.' },
    retry: 'Try again',
    home: 'Go to shops',
    code: 'Error code'
  },
  ru: {
    error: { title: 'Что-то пошло не так', body: 'Не удалось загрузить раздел. Данные не пострадали — попробуйте ещё раз.' },
    notFound: { title: 'Здесь ничего нет', body: 'Страница или запись не существует либо была удалена.' },
    retry: 'Повторить',
    home: 'К списку клиентов',
    code: 'Код ошибки'
  },
  tk: {
    error: { title: 'Bir zat nädogry boldy', body: 'Bölümi ýükläp bolmady. Maglumatlaryňyz howpsuz — birazdan gaýtadan synanyşyň.' },
    notFound: { title: 'Bu ýerde hiç zat ýok', body: 'Bu sahypa ýa-da ýazgy ýok ýa-da pozuldy.' },
    retry: 'Gaýtadan synanyş',
    home: 'Müşderiler sanawyna',
    code: 'Ýalňyşlyk kody'
  }
}

const noop = () => () => {}
const lang = pageLocale

/** In-page fallback for failed loads and missing records; the sidebar and header stay usable. */
export function ErrorState ({ kind = 'error', retry, digest }: { kind?: 'error' | 'notFound', retry?: () => void, digest?: string }) {
  const t = text[useSyncExternalStore(noop, lang, () => DEFAULT_LOCALE)]
  const m = t[kind]
  return (
    <div role={kind === 'error' ? 'alert' : undefined} className='anim-rise-in flex min-h-[60vh] flex-col items-center justify-center gap-4 p-8 text-center'>
      <span className={`flex size-14 items-center justify-center rounded-full text-2xl font-bold ${kind === 'error' ? 'bg-error-bg text-error' : 'bg-line text-accent'}`}>{kind === 'error' ? '!' : '?'}</span>
      <div className='flex max-w-md flex-col gap-1.5'>
        <h1 className='text-xl font-bold leading-7 text-ink'>{m.title}</h1>
        <p className='text-sm leading-5 text-muted'>{m.body}</p>
        {digest != null && <p className='font-mono text-[11px] text-subtle'>{t.code}: {digest}</p>}
      </div>
      <div className='flex items-center gap-3'>
        {retry != null && (
          <button data-ripple type='button' onClick={retry} className='rounded-lg bg-accent px-5 py-2 text-sm font-semibold leading-5 text-white shadow-[0px_1px_2px_rgba(0,0,0,0.05)] hover:shadow-md'>{t.retry}</button>
        )}
        <Link data-ripple href='/shops' className='rounded-lg border border-border bg-pure-white px-5 py-2 text-sm font-medium leading-5 text-default-black hover:border-slate-400'>{t.home}</Link>
      </div>
    </div>
  )
}
