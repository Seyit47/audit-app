import 'dotenv/config'
import { createPrisma } from '../src/lib/prisma.js'
import { newId } from '../src/lib/ids.js'

const prisma = createPrisma(process.env.DATABASE_URL!)

const regions = ['Region 1 (Central Hub)', 'Region 2 (West District)', 'Region 3 (North Sector)', 'Region 4 (East Coast)']
const categories = ['Cosmetics', 'Hair Care', 'Salon Supplies', 'Styling']

await prisma.companySettings.upsert({ where: { id: 1 }, update: {}, create: { id: 1 } })
for (const name of regions) {
  await prisma.region.upsert({ where: { name }, update: {}, create: { id: newId(), name } })
}
for (const name of categories) {
  await prisma.productCategory.upsert({ where: { name }, update: {}, create: { id: newId(), name } })
}
console.log('Seeded settings, regions and product categories.')
await prisma.$disconnect()
