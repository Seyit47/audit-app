import type { LucideIcon } from 'lucide-react';

interface EmptyStateProps {
  icon: LucideIcon;
  message: string;
}

export function EmptyState({ icon: Icon, message }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 rounded-xl border border-border bg-surface p-12 text-center text-text-muted">
      <Icon className="size-8 text-accent" aria-hidden />
      <p>{message}</p>
    </div>
  );
}
