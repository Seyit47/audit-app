import { Button } from '@/components/ui/Button'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { PageHeader } from '@/components/ui/PageHeader'
import { getProduct, listCategories, listProducts, type ProductListQuery } from '@/features/products/api'
import { ProductFormDialog } from '@/features/products/components/ProductFormDialog'
import { ProductsToolbar } from '@/features/products/components/ProductsToolbar'
import { ProductsView } from '@/features/products/components/ProductsView'
import { productsCopy } from '@/features/products/copy'
import { getLocale } from '@/lib/locale'

type Search = Record<string, string | undefined>

export default async function ProductsPage ({ searchParams }: PageProps<'/products'>) {
  const sp = (await searchParams) as Search
  const copy = productsCopy[await getLocale()]
  const query: ProductListQuery = { page: Number(sp.page ?? 1), size: Number(sp.size ?? 10), q: sp.q, status: sp.status as ProductListQuery['status'] }
  const dialog = sp.add != null || sp.edit != null
  const [page, categories, editing] = await Promise.all([
    listProducts(query),
    dialog ? listCategories() : Promise.resolve([]),
    sp.edit != null ? getProduct(sp.edit) : Promise.resolve(null)
  ])
  const keep = (omit: string[]) => new URLSearchParams(Object.entries(sp).filter((e): e is [string, string] => e[1] != null && !omit.includes(e[0])))
  const exportHref = `/export?${new URLSearchParams({ type: 'PRODUCTS_XLSX', back: '/products', ...Object.fromEntries(keep(['page', 'size', 'add', 'edit', 'exportFailed'])) }).toString()}`

  return (
    <div className='flex flex-col gap-2.5 p-4'>
      <PageHeader
        title={copy.title} badge={copy.badge} description={copy.description}
        actions={
          <>
            <Button variant='secondary' href={exportHref} icon={<FigmaIcon name='export' width={13} height={13} />}>{copy.exportCatalog}</Button>
            <Button href='/products?add=1' icon={<FigmaIcon name='plus' width={10.5} height={10.5} />}>{copy.addProduct}</Button>
          </>
        }
      />
      {sp.exportFailed != null && <p role='alert' className='text-sm text-error'>{copy.exportFailed}</p>}
      <ProductsToolbar copy={copy} />
      <ProductsView page={page} copy={copy} />
      {dialog && <ProductFormDialog key={editing?.id ?? 'new'} product={editing} categories={categories} copy={copy} closeHref={`/products?${keep(['add', 'edit']).toString()}`} />}
    </div>
  )
}
