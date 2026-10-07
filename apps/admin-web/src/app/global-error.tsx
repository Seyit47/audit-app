'use client'

// Last resort when the root layout itself fails: a self-contained page (no app styles load here).
export default function GlobalError ({ retry }: { error: Error & { digest?: string }, retry: () => void }) {
  return (
    <html lang='ru'>
      <body style={{ margin: 0, minHeight: '100vh', display: 'grid', placeItems: 'center', fontFamily: 'system-ui, sans-serif', background: '#fbf8ff', color: '#1b1b21' }}>
        <title>Ошибка</title>
        <div style={{ textAlign: 'center', padding: 24 }}>
          <h1 style={{ fontSize: 20 }}>Что-то пошло не так / Something went wrong</h1>
          <button type='button' onClick={() => retry()} style={{ marginTop: 12, padding: '8px 20px', border: 0, borderRadius: 8, background: '#493ee5', color: '#fff', fontWeight: 600, cursor: 'pointer' }}>Повторить / Try again</button>
        </div>
      </body>
    </html>
  )
}
