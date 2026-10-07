/** "Filtered view: 84 locations • 3 salesmen • 1 region" pill of 21:2 (3:382). */
export function FilterBanner ({ text }: { text: string }) {
  return (
    <span className='flex h-7 items-center gap-1.5 rounded-full bg-[#e2dfff] px-2.5 text-[11px] font-semibold leading-4 text-black shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
      <span className='size-1.5 rounded-full bg-accent' />{text}
    </span>
  )
}
