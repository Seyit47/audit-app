import { Icon } from './Icon'

/** Search input of 30:574 / header 3:853. Submits as a GET form field. */
export function SearchField ({ name = 'q', placeholder, defaultValue, className = 'w-[350px]' }: { name?: string, placeholder: string, defaultValue?: string, className?: string }) {
  return (
    <div className={`relative ${className}`}>
      <Icon name='search' width={15} height={15} className='pointer-events-none absolute left-[14.5px] top-[12.5px] text-muted' />
      <input
        name={name} type='search' placeholder={placeholder} aria-label={placeholder} defaultValue={defaultValue}
        className='h-10 w-full rounded-lg bg-secondary-bg pl-10 pr-4 text-sm text-ink placeholder:text-muted hover:bg-line focus:bg-pure-white focus:outline-none focus:ring-2 focus:ring-accent/30 disabled:cursor-not-allowed disabled:opacity-50'
      />
    </div>
  )
}
