/** Initials avatars of 3:407: 36 px shop tile (30:1856) and 24 px salesman circle (30:1882). */
export function initials (name: string): string {
  return name.split(/\s+/).filter(Boolean).slice(0, 2).map((w) => w[0]!.toUpperCase()).join('')
}

export function Avatar ({ name, size = 'sm', tone = 'muted', src }: { name: string, size?: 'sm' | 'lg', tone?: 'accent' | 'muted', src?: string | null }) {
  const box = size === 'lg'
    ? `size-9 rounded-lg text-xs font-semibold leading-4 ${tone === 'accent' ? 'bg-accent text-[#fefaff] drop-shadow-[0px_1px_1px_rgba(0,0,0,0.05)]' : 'bg-line text-muted'}`
    : 'size-6 rounded-full bg-line text-[10px] font-bold leading-5 text-accent'
  return (
    <span className={`flex shrink-0 items-center justify-center overflow-hidden text-center ${box}`}>
      {/* eslint-disable-next-line @next/next/no-img-element -- presigned URL from the API */}
      {src != null ? <img src={src} alt='' className='size-full object-cover' /> : initials(name)}
    </span>
  )
}
