'use client'

import { usePathname } from 'next/navigation'
import type { ReactNode } from 'react'

// The Map (21:2) is full-bleed with its own floating search bar, so it has no header.
const WITHOUT_HEADER = new Set(['/map'])

export function TopbarGate ({ children }: { children: ReactNode }) {
  return WITHOUT_HEADER.has(usePathname()) ? null : children
}
