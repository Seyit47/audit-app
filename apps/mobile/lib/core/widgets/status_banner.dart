import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';

enum _StatusKind { checking, connected, unreachable }

/// Compact backend connection status, reused wherever the app shows connectivity.
class StatusBanner extends StatelessWidget {
  const StatusBanner.checking({super.key})
    : _kind = _StatusKind.checking,
      version = null,
      onRetry = null;

  const StatusBanner.connected({super.key, required String this.version})
    : _kind = _StatusKind.connected,
      onRetry = null;

  const StatusBanner.unreachable({
    super.key,
    required VoidCallback this.onRetry,
  }) : _kind = _StatusKind.unreachable,
       version = null;

  final _StatusKind _kind;
  final String? version;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final (color, message) = switch (_kind) {
      _StatusKind.checking => (colors.textMuted, l10n.statusChecking),
      _StatusKind.connected => (colors.success, l10n.statusConnected(version!)),
      _StatusKind.unreachable => (colors.error, l10n.statusUnreachable),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
