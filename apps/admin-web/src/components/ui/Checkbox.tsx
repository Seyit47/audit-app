import type { InputHTMLAttributes } from 'react'

/** Row checkbox of 3:407 (16 px, #767676 border, 2.5 px radius). */
export function Checkbox (props: InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      type='checkbox' {...props}
      className='size-4 shrink-0 cursor-pointer appearance-none rounded-[2.5px] border border-checkbox bg-pure-white transition-[background-color,border-color,box-shadow,transform] duration-150 hover:shadow-[0_0_0_6px_rgba(73,62,229,0.08)] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent active:scale-90 disabled:cursor-not-allowed disabled:opacity-50 disabled:shadow-none aria-invalid:border-error checked:border-accent checked:bg-accent checked:bg-[url("data:image/svg+xml,%3Csvg%20xmlns=%27http://www.w3.org/2000/svg%27%20viewBox=%270%200%2016%2016%27%3E%3Cpath%20d=%27M4%208l3%203%205-6%27%20fill=%27none%27%20stroke=%27white%27%20stroke-width=%272%27/%3E%3C/svg%3E")]'
    />
  )
}
