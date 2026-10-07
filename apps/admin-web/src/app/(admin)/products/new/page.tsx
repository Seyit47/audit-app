import { redirect } from 'next/navigation'

/** Add Product (495:2311) is a dialog over the Products list. */
export default function NewProduct () {
  redirect('/products?add=1')
}
