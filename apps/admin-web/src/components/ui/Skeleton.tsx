/** Shimmer placeholders shown by the route `loading.tsx` files while a page renders. */
export function Bone ({ className = '' }: { className?: string }) {
  return <div className={`skeleton ${className}`} />
}

function Header ({ actions = 2 }: { actions?: number }) {
  return (
    <div className='flex items-center justify-between'>
      <div className='flex flex-col gap-2'>
        <Bone className='h-8 w-56' />
        <Bone className='h-4 w-96' />
      </div>
      <div className='flex gap-3'>{Array.from({ length: actions }, (_, i) => <Bone key={i} className='h-9 w-32' />)}</div>
    </div>
  )
}

function Table ({ rows = 8 }: { rows?: number }) {
  return (
    <div className='overflow-hidden rounded-xl bg-pure-white shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
      <div className='h-12 bg-secondary-bg' />
      {Array.from({ length: rows }, (_, i) => (
        <div key={i} className='flex h-[69px] items-center gap-4 border-t border-secondary-bg px-4'>
          <Bone className='size-9 rounded-full' />
          <div className='flex flex-1 flex-col gap-2'><Bone className='h-3.5 w-48' /><Bone className='h-3 w-32' /></div>
          <Bone className='h-3.5 w-20' /><Bone className='h-3.5 w-24' /><Bone className='h-5 w-16 rounded-full' />
        </div>
      ))}
    </div>
  )
}

export function ListSkeleton ({ stats = false }: { stats?: boolean }) {
  return (
    <div className='route-skeleton flex flex-col gap-2.5 p-4'>
      <Header />
      {stats && <div className='grid grid-cols-6 gap-3.5'>{Array.from({ length: 6 }, (_, i) => <Bone key={i} className='h-[125px] rounded-2xl' />)}</div>}
      <Bone className='h-16 rounded-xl' />
      <Table />
    </div>
  )
}

export function DetailsSkeleton () {
  return (
    <div className='route-skeleton flex flex-col gap-4 p-4'>
      <Bone className='h-4 w-64' />
      <Bone className='h-24 rounded-xl' />
      <div className='flex gap-4'>
        <div className='flex flex-1 flex-col gap-4'>
          <div className='grid grid-cols-3 gap-4'>{Array.from({ length: 3 }, (_, i) => <Bone key={i} className='h-[152px] rounded-xl' />)}</div>
          <Bone className='h-[352px] rounded-xl' />
        </div>
        <div className='flex flex-1 flex-col gap-3.5'>{Array.from({ length: 3 }, (_, i) => <Bone key={i} className='h-48 rounded-xl' />)}</div>
      </div>
    </div>
  )
}

export function GridSkeleton () {
  return (
    <div className='route-skeleton flex flex-col gap-2.5 p-4'>
      <Header />
      <div className='flex gap-3'>{Array.from({ length: 4 }, (_, i) => <Bone key={i} className='h-10 w-40' />)}</div>
      <div className='grid grid-cols-4 gap-2.5'>{Array.from({ length: 12 }, (_, i) => <Bone key={i} className='aspect-[287/170] rounded-xl' />)}</div>
    </div>
  )
}

export function FormSkeleton () {
  return (
    <div className='route-skeleton flex flex-col gap-4 p-4'>
      <Header actions={0} />
      <div className='grid grid-cols-[3fr_2fr] gap-4'>
        <div className='flex flex-col gap-4'>{Array.from({ length: 3 }, (_, i) => <Bone key={i} className='h-48 rounded-xl' />)}</div>
        <Bone className='h-80 rounded-xl' />
      </div>
    </div>
  )
}

export function MapSkeleton () {
  return <div className='route-skeleton h-screen pl-4'><div className='size-full bg-secondary-bg' /></div>
}
