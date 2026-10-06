import { v7 } from 'uuid'

/** Time-ordered UUID v7 for server-created records. */
export const newId = (): string => v7()
