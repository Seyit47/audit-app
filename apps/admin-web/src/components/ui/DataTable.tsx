import Link from 'next/link'
import type { ReactNode } from 'react'
import { FigmaIcon } from './FigmaIcon'

export interface Column<T> {
  key: string
  header: ReactNode
  /** Figma column width in px: the column's minimum, and its share of any extra width. */
  width?: number
  /** Keeps exactly its width (checkbox, row menu); a column without a width is a 56 px row-menu column. */
  fixed?: boolean
  /** Cell padding/alignment classes; header and body share them. */
  className?: string
  /** Makes the header a sort link (31:2307). */
  sortKey?: string
  render: (row: T) => ReactNode
}

export interface TableSort { key: string, dir: 'asc' | 'desc', href: (key: string, dir: 'asc' | 'desc') => string }

const MENU_WIDTH = 56

// comfortable: Shops/Products (3:407, 30:574). compact: Salesmen (31:2307).
const densities = {
  comfortable: {
    th: 'py-[13px] text-[11px] font-bold uppercase leading-5 tracking-[0.55px] text-muted',
    tr: 'h-[69px] border-t border-secondary-bg first:border-t-0',
    selected: 'bg-row-selected'
  },
  compact: {
    th: 'py-5 text-xs font-bold uppercase leading-4 tracking-[0.6px] text-muted',
    tr: 'h-14 border-t border-dark-accent first:border-t-0',
    selected: 'bg-accent/5'
  }
}

/**
 * Table of 3:407 / 30:574 / 31:2307: tinted header row, uppercase headings, divided rows,
 * highlighted selection. Selection checkboxes are rendered by the caller as a column.
 */
export function DataTable<T> ({ columns, rows, rowKey, isSelected, rowClassName, footer, empty, density = 'comfortable', sort }: {
  columns: Column<T>[]
  rows: T[]
  rowKey: (row: T) => string
  isSelected?: (row: T) => boolean
  rowClassName?: (row: T) => string
  footer?: ReactNode
  empty?: ReactNode
  density?: keyof typeof densities
  sort?: TableSort
}) {
  const d = densities[density]
  // Content columns grow with the table in proportion to their Figma widths (which are their minimum);
  // fixed columns keep their size. Below the Figma total the table scrolls sideways instead of squeezing.
  const isFixed = (c: Column<T>) => c.fixed === true || c.width == null
  const px = (c: Column<T>) => c.width ?? MENU_WIDTH
  const fixedTotal = columns.filter(isFixed).reduce((sum, c) => sum + px(c), 0)
  const flexTotal = columns.filter((c) => !isFixed(c)).reduce((sum, c) => sum + px(c), 0)
  // Percentages (browsers ignore calc() on table columns): at the Figma total width each content column
  // gets exactly its Figma size; wider tables share the extra space by the same proportions.
  const flexShare = 1
  const colWidth = (c: Column<T>) => isFixed(c) || flexTotal === 0 ? `${px(c)}px` : `${(px(c) / flexTotal) * flexShare * 100}%`
  return (
    <div className='w-full overflow-x-auto rounded-xl bg-pure-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]'>
      <table className='w-full table-fixed border-collapse' style={{ minWidth: fixedTotal + flexTotal }}>
        <colgroup>{columns.map((c) => <col key={c.key} style={{ width: colWidth(c) }} />)}</colgroup>
        <thead className='bg-secondary-bg'>
          <tr>
            {columns.map((c) => (
              <th key={c.key} scope='col' className={`text-left align-middle ${d.th} ${c.className ?? 'px-3'}`}>
                {c.sortKey != null && sort != null ? <SortLink column={c} sort={sort} /> : c.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className='anim-stagger'>
          {rows.length === 0 && empty != null && (
            <tr><td colSpan={columns.length} className='px-4 py-10 text-center text-sm text-muted'>{empty}</td></tr>
          )}
          {rows.map((row, i) => (
            <tr
              key={rowKey(row)} style={{ '--i': i } as React.CSSProperties}
              className={`${d.tr} transition-colors duration-150 hover:bg-secondary-bg/40 ${isSelected?.(row) === true ? d.selected : ''} ${rowClassName?.(row) ?? ''}`}
            >
              {columns.map((c) => (
                <td key={c.key} className={`align-middle text-xs leading-4 text-ink ${c.className ?? 'px-3'}`}>{c.render(row)}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      {footer}
    </div>
  )
}

function SortLink<T> ({ column, sort }: { column: Column<T>, sort: TableSort }) {
  const active = sort.key === column.sortKey
  const nextDir = active && sort.dir === 'asc' ? 'desc' : 'asc'
  return (
    <Link href={sort.href(column.sortKey!, nextDir)} scroll={false} className='inline-flex items-center gap-1 align-middle' aria-sort={active ? (sort.dir === 'asc' ? 'ascending' : 'descending') : undefined}>
      <span className='whitespace-pre-line'>{column.header}</span>
      {active
        ? <FigmaIcon name='sort-active' width={9.333} height={9.333} className={sort.dir === 'asc' ? 'rotate-180' : ''} />
        : <FigmaIcon name='sort-both' width={5.25} height={10.44} className='opacity-40' />}
    </Link>
  )
}
