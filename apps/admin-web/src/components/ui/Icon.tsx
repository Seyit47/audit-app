import type { CSSProperties } from 'react'
import { iconSrc } from './FigmaIcon'

/**
 * Renders a Figma-exported SVG from /public/icons in `currentColor` at the SVG's own size.
 * The SVG is used as a mask so one file can take any text color.
 */
export function Icon ({ name, width, height, className = '' }: { name: string, width: number, height: number, className?: string }) {
  const style: CSSProperties = {
    width,
    height,
    maskImage: `url(${iconSrc(name)})`,
    maskSize: '100% 100%',
    maskRepeat: 'no-repeat',
    backgroundColor: 'currentColor'
  }
  return <span aria-hidden className={`inline-block shrink-0 ${className}`} style={style} />
}
