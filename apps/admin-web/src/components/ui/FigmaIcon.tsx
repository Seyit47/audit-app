/** A Figma-exported SVG from /public/icons with its own colors, at its Figma size. */
export function FigmaIcon ({ name, width, height, className = '' }: { name: string, width: number, height: number, className?: string }) {
  // eslint-disable-next-line @next/next/no-img-element -- static SVG at its exported size
  return <img src={`/icons/${name}.svg`} alt='' aria-hidden width={width} height={height} className={`shrink-0 ${className}`} style={{ width, height }} />
}
