import type { Metadata } from 'next'
import { SignInForm } from '@/features/auth/components/SignInForm'
import { authCopy } from '@/features/auth/copy'
import { getCopy } from '@/lib/locale'

export const metadata: Metadata = { title: 'Audit' }

/** Sign-in (approved exception G1): the dialog surface, FormField and Button of 162:20071. */
export default async function LoginPage () {
  const copy = await getCopy(authCopy)
  return (
    <main className='flex min-h-screen items-center justify-center bg-main-bg p-6'>
      <div className='flex w-[400px] flex-col gap-6 rounded-2xl bg-pure-white p-8 shadow-[0px_25px_50px_-12px_rgba(15,23,42,0.15)]'>
        <div className='flex items-center gap-3'>
          <span className='flex size-9 items-center justify-center rounded-lg bg-accent'>
            {/* eslint-disable-next-line @next/next/no-img-element -- static Figma SVG */}
            <img src='/icons/logo.svg' alt='' width={18.2875} height={18.2417} />
          </span>
          <div className='flex flex-col'>
            <h1 className='text-lg font-bold leading-6 text-black'>{copy.title}</h1>
            <p className='text-xs leading-4 text-default-black'>{copy.subtitle}</p>
          </div>
        </div>
        <SignInForm copy={copy} />
      </div>
    </main>
  )
}
