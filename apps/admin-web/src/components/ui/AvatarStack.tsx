import { Avatar } from './Avatar'

/**
 * Several people in one cell: up to [max] overlapping initials circles and a "+N" for the rest, their names
 * beside (one or two in full, else a count). The names are the tooltip.
 */
export function AvatarStack ({ people, max = 3, names = true, summary }: {
  people: Array<{ id: string, fullName: string }>
  max?: number
  /** The names beside the circles (off in tight cells: the tooltip still has them). */
  names?: boolean
  /** "{n} salesmen", for three or more. */
  summary: (n: number) => string
}) {
  const shown = people.slice(0, max)
  const rest = people.length - shown.length
  const title = people.map((p) => p.fullName).join(', ')
  return (
    <span className='flex min-w-0 items-center gap-2' title={title}>
      <span className='flex shrink-0 items-center -space-x-1.5'>
        {shown.map((p) => (
          <span key={p.id} className='rounded-full ring-2 ring-pure-white'><Avatar name={p.fullName} /></span>
        ))}
        {rest > 0 && (
          <span className='flex size-6 items-center justify-center rounded-full bg-dark-accent text-[10px] font-bold leading-5 text-accent ring-2 ring-pure-white'>+{rest}</span>
        )}
      </span>
      {names && (
        <span className='truncate font-medium'>{people.length <= 2 ? title : summary(people.length)}</span>
      )}
    </span>
  )
}
