/** Each page enters with a short fade and rise (Material shared-axis Y); search-param changes don't remount it. */
export default function Template ({ children }: { children: React.ReactNode }) {
  return <div className='anim-rise-in'>{children}</div>
}
