/** URL of an icon in /public/icons, versioned by the icons' contents so it can be cached for good (next.config). */
export const iconSrc = (name: string) => `/icons/${name}.svg?v=${process.env.ICONS_VERSION}`

/** A Figma-exported SVG from /public/icons with its own colors, at its Figma size. */
export function FigmaIcon ({ name, width, height, className = '' }: { name: string, width: number, height: number, className?: string }) {
  // eslint-disable-next-line @next/next/no-img-element -- static SVG at its exported size
  return <img src={iconSrc(name)} alt='' aria-hidden width={width} height={height} className={`shrink-0 ${className}`} style={{ width, height }} />
}
