// Operator CLI for admin accounts (approved gap resolution A5: no admin screen in Figma).
// Usage: pnpm admin:create --email a@b.c --password secret | pnpm admin:reset-password --email a@b.c --password new
import 'dotenv/config'
import { parseArgs } from 'node:util'
import argon2 from 'argon2'
import { createPrisma } from '../src/lib/prisma.js'
import { newId } from '../src/lib/ids.js'

const [command, ...rest] = process.argv.slice(2)
// `pnpm admin:create -- --email …` forwards the `--`; drop it.
const { values } = parseArgs({ args: rest.filter((a, i) => !(i === 0 && a === '--')), options: { email: { type: 'string' }, password: { type: 'string' } } })
if (!values.email || !values.password || values.password.length < 8) {
  console.error('Required: --email and --password (min 8 characters)')
  process.exit(1)
}

const prisma = createPrisma(process.env.DATABASE_URL!)
const passwordHash = await argon2.hash(values.password, { type: argon2.argon2id })

if (command === 'create') {
  if (await prisma.user.findUnique({ where: { email: values.email } }) != null) {
    console.error(`${values.email} already exists.`)
    process.exit(1)
  }
  await prisma.user.create({ data: { id: newId(), role: 'ADMIN', email: values.email, passwordHash } })
  console.log(`Admin ${values.email} created.`)
} else if (command === 'reset-password') {
  const user = await prisma.user.findUnique({ where: { email: values.email } })
  if (user == null || user.role !== 'ADMIN') {
    console.error(`No admin with email ${values.email}.`)
    process.exit(1)
  }
  await prisma.user.update({ where: { email: values.email }, data: { passwordHash } })
  await prisma.refreshToken.updateMany({ where: { user: { email: values.email } }, data: { revokedAt: new Date() } })
  console.log(`Password reset for ${values.email}.`)
} else {
  console.error('Commands: create | reset-password')
  process.exit(1)
}
await prisma.$disconnect()
