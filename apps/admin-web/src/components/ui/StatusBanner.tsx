import type { ReactNode } from 'react';

type Variant = 'info' | 'success' | 'error';

const variantClasses: Record<Variant, string> = {
  info: 'text-text-muted',
  success: 'text-success',
  error: 'text-error',
};

interface StatusBannerProps {
  variant: Variant;
  children: ReactNode;
  action?: { label: string; onClick: () => void };
}

/** One-line status message with an optional action, e.g. "Retry". */
export function StatusBanner({ variant, children, action }: StatusBannerProps) {
  return (
    <div role="status" className={`flex items-center gap-2 text-sm ${variantClasses[variant]}`}>
      <span className="size-2 shrink-0 rounded-full bg-current" aria-hidden />
      <span>{children}</span>
      {action && (
        <button
          type="button"
          onClick={action.onClick}
          className="rounded-md px-2 py-1 font-medium text-accent hover:bg-accent-soft"
        >
          {action.label}
        </button>
      )}
    </div>
  );
}
