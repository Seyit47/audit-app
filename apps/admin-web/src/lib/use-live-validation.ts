'use client'

import { useCallback, useState, type FormEvent } from 'react'

/** A field's rule: its message when the value is wrong, otherwise null. `get` reads any other field of the form. */
export type FieldRule = (value: string, get: (name: string) => string) => string | null

/**
 * Field errors as the user types. A field shows its error once it is dirty (the user changed it); Save marks every
 * field dirty. Rules run on the whole form on every input, so a field that depends on another (audit plan ≤ visit
 * plan, password confirmation) updates when either changes. Fields are read by `name` from the form, so
 * uncontrolled and controlled inputs both work.
 */
export function useLiveValidation (rules: Record<string, FieldRule>) {
  const [dirty, setDirty] = useState<ReadonlySet<string>>(new Set())
  const [errors, setErrors] = useState<Record<string, string | null>>({})

  const check = useCallback((form: HTMLFormElement) => {
    const data = new FormData(form)
    const get = (name: string) => String(data.get(name) ?? '')
    return Object.fromEntries(Object.entries(rules).map(([name, rule]) => [name, rule(get(name).trim(), get)]))
  }, [rules])

  /** Put on the <form>: input and change events bubble up from every field. */
  const onInput = (e: FormEvent<HTMLFormElement>) => {
    const name = (e.target as HTMLInputElement).name
    setErrors(check(e.currentTarget))
    if (name in rules && !dirty.has(name)) setDirty(new Set(dirty).add(name))
  }

  /** Save: shows every error; true when the form is valid. */
  const validate = (form: HTMLFormElement) => {
    const next = check(form)
    setErrors(next)
    setDirty(new Set(Object.keys(rules)))
    return Object.values(next).every((e) => e == null)
  }

  /** The field's message, for FormField's `error`. */
  const error = (name: string) => (dirty.has(name) ? errors[name] ?? undefined : undefined)

  return { onInput, validate, error }
}
