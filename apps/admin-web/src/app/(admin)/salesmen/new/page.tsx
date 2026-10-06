import { redirect } from 'next/navigation'

/** The Add Salesman dialog lives on the list (495:3932 is a dialog over 31:2307). */
export default function NewSalesman () {
  redirect('/salesmen?add=1')
}
