import type { ReactNode } from 'react'

export interface Column<T> {
  key: string
  header: ReactNode
  /** Figma column width in px. */
  width?: number
  /** Cell padding/alignment classes; header and body share them. */
  className?: string
  render: (row: T) => ReactNode
}

/**
 * Table of 3:407 / 30:574: tinted header row, 11 px uppercase headings, divided rows,
 * highlighted selection. Selection checkboxes are rendered by the caller as a column.
 */
export function DataTable<T> ({ columns, rows, rowKey, isSelected, footer, empty }: {
  columns: Column<T>[]
  rows: T[]
  rowKey: (row: T) => string
  isSelected?: (row: T) => boolean
  footer?: ReactNode
  empty?: ReactNode
}) {
  return (
    <div className='w-full overflow-clip rounded-xl bg-pure-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]'>
      <table className='w-full table-fixed border-collapse'>
        <colgroup>{columns.map((c) => <col key={c.key} style={c.width != null ? { width: c.width } : undefined} />)}</colgroup>
        <thead className='bg-secondary-bg'>
          <tr>
            {columns.map((c) => (
              <th key={c.key} scope='col' className={`py-[13px] text-left align-middle text-[11px] font-bold uppercase leading-5 tracking-[0.55px] text-muted ${c.className ?? 'px-3'}`}>
                {c.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 && empty != null && (
            <tr><td colSpan={columns.length} className='px-4 py-10 text-center text-sm text-muted'>{empty}</td></tr>
          )}
          {rows.map((row) => (
            <tr key={rowKey(row)} className={`h-[69px] border-t border-secondary-bg first:border-t-0 ${isSelected?.(row) === true ? 'bg-row-selected' : ''}`}>
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
