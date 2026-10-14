import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/sync/outbox_groups.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/adaptive.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/bottom_sheet_card.dart';
import '../../../core/widgets/buttons.dart';

/// What is still on the phone (opened from the Home sync pill): each audit or new shop with its
/// photos, what is uploading and how far, and Stop / Resume / Send again per item.
/// Not a Figma frame (approved exception), built from the app's cards and styles.
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(outboxGroupsProvider).value ?? const <OutboxGroup>[];
    final progress = ref.watch(syncProgressProvider);
    final sync = ref.read(syncControllerProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: l10n.syncTitle, count: groups.length),
            Expanded(
              child: groups.isEmpty
                  ? Center(
                      child: Text(l10n.syncEmpty, style: AppTextStyles.body.copyWith(color: context.colors.textSecondary)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: groups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final g = groups[i];
                        final sending = g.ids.any(progress.containsKey);
                        return OutboxGroupCard(
                          group: g,
                          progress: progress,
                          actions: [
                            if (g.paused)
                              TextButton(onPressed: () => sync.resume(g), child: Text(l10n.syncResume))
                            else ...[
                              if (g.rejected)
                                TextButton(
                                  onPressed: sending ? null : () => _confirmDiscard(context, () => sync.discard(g)),
                                  style: TextButton.styleFrom(foregroundColor: context.colors.error),
                                  child: Text(l10n.syncDelete),
                                )
                              else
                                TextButton(onPressed: () => sync.stop(g), child: Text(l10n.syncStop)),
                              TextButton(onPressed: sending ? null : () => sync.resume(g), child: Text(l10n.syncRetry)),
                            ],
                          ],
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: PrimaryButton(label: l10n.syncNow, loading: ref.watch(syncControllerProvider).running, onPressed: () => unawaited(sync.syncNow())),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDiscard(BuildContext context, Future<void> Function() discard) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showAppDialog<bool>(
    context: context,
    title: Text(l10n.syncDeleteTitle),
    content: Text(l10n.syncDeleteBody),
    actions: (dialog) => [
      AppDialogAction(label: l10n.cancel, onPressed: () => Navigator.pop(dialog, false)),
      AppDialogAction(label: l10n.syncDelete, primary: true, onPressed: () => Navigator.pop(dialog, true)),
    ],
  );
  if (ok ?? false) await discard();
}

/// The shop an audit was made in, for its title.
final _shopNameProvider = FutureProvider.autoDispose.family<String?, String>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return (await (db.select(db.shops)..where((s) => s.id.equals(id))).getSingleOrNull())?.name;
});

String? _payload(OutboxData? item, String key) => item == null ? null : (jsonDecode(item.payloadJson) as Map<String, dynamic>)[key] as String?;

/// One audit or new shop: title, state, and a row per photo with its upload progress.
/// [sent] lists photos that already reached the server (the sending sheet keeps them, ticked).
class OutboxGroupCard extends ConsumerWidget {
  const OutboxGroupCard({super.key, required this.group, required this.progress, this.sent = const [], this.actions = const []});

  final OutboxGroup group;
  final Map<String, double> progress;
  final List<String> sent;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final record = group.record;
    final title = switch (record?.kind) {
      OutboxKind.auditCreate => l10n.syncAudit(ref.watch(_shopNameProvider(_payload(record, 'shopId') ?? '')).value ?? '…'),
      OutboxKind.shopCreate => l10n.syncNewShop(_payload(record, 'name') ?? ''),
      _ => l10n.syncPhoto(1),
    };
    final sending = group.ids.any(progress.containsKey);
    final error = group.error;
    final (status, color) = sending
        ? (l10n.syncSending, c.accent)
        : group.paused
        ? (l10n.syncPaused, c.textSecondary)
        : error == null
        ? (l10n.syncWaiting, c.textSecondary)
        : error.startsWith('NETWORK')
        ? (l10n.syncNoConnection, c.error)
        : (l10n.syncError(error), c.error);
    final photos = [
      for (final path in sent) (path: path, fraction: 1.0, done: true),
      for (final p in group.photos) (path: _payload(p, 'localPath'), fraction: progress[p.id], done: false),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
          for (final (i, p) in photos.indexed) ...[
            const SizedBox(height: 10),
            _PhotoRow(path: p.path, label: l10n.syncPhoto(i + 1), fraction: p.fraction, done: p.done),
          ],
          if (actions.isNotEmpty) Row(mainAxisAlignment: MainAxisAlignment.end, children: actions) else const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({required this.path, required this.label, required this.fraction, required this.done});

  final String? path;
  final String label;

  /// Null: waiting.
  final double? fraction;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final f = fraction;
    return Row(
      children: [
        AppImage(path, width: 40, height: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(color: c.textPrimary)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: done ? 1 : f ?? 0,
                  minHeight: 4,
                  backgroundColor: c.darkAccent,
                  valueColor: AlwaysStoppedAnimation(done ? c.success : c.accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: done
              ? Icon(Icons.check_circle, size: 18, color: c.success)
              : Text(
                  f == null ? '—' : '${(f * 100).round()}%',
                  textAlign: TextAlign.end,
                  style: AppTextStyles.caption.copyWith(color: c.textSecondary),
                ),
        ),
      ],
    );
  }
}

/// After "Завершить аудит" / "Сохранить": online, sends the record at once and shows each photo's
/// upload (if that fails, the outbox keeps it and the sheet says so); offline, only [savedOffline]
/// is shown. Returns when the sheet is closed.
Future<void> sendNow(BuildContext context, WidgetRef ref, {required String recordId, required String savedOffline}) async {
  if (!await ref.read(isOnlineProvider)()) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(savedOffline)));
    return;
  }
  if (!context.mounted) return;
  final sheet = _SendSheet(recordId: recordId);
  await (context.isCupertino
      ? showCupertinoModalPopup<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => Material(type: MaterialType.transparency, child: sheet),
        )
      : showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (_) => sheet,
        ));
}

class _SendSheet extends ConsumerStatefulWidget {
  const _SendSheet({required this.recordId});

  final String recordId;

  @override
  ConsumerState<_SendSheet> createState() => _SendSheetState();
}

class _SendSheetState extends ConsumerState<_SendSheet> {
  /// The group as first seen, so photos already sent stay listed (ticked).
  OutboxGroup? _first;
  bool _pushed = false;
  Timer? _close;

  @override
  void initState() {
    super.initState();
    unawaited(
      ref.read(syncControllerProvider.notifier).pushNow().whenComplete(() {
        if (mounted) setState(() => _pushed = true);
      }),
    );
  }

  @override
  void dispose() {
    _close?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final groups = ref.watch(outboxGroupsProvider);
    final progress = ref.watch(syncProgressProvider);
    final group = groups.value?.where((g) => g.record?.id == widget.recordId).firstOrNull;
    if (group != null) _first ??= group;
    final done = groups.hasValue && group == null;
    final failed = !done && _pushed;
    if (done) _close ??= Timer(const Duration(milliseconds: 900), () => mounted ? Navigator.pop(context) : null);

    final first = _first;
    final open = {...?group?.ids};
    final shown = group ?? first;
    return BottomSheetCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              if (done)
                Icon(Icons.check_circle, color: c.success, size: 22)
              else if (failed)
                Icon(Icons.cloud_off, color: c.error, size: 22)
              else
                SizedBox.square(dimension: 18, child: CircularProgressIndicator.adaptive(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(c.accent))),
              const SizedBox(width: 12),
              Expanded(
                child: Text(done ? l10n.syncSent : l10n.sendingTitle, style: AppTextStyles.heading.copyWith(color: c.textPrimary)),
              ),
            ],
          ),
          if (failed) ...[const SizedBox(height: 8), Text(l10n.sendFailed, style: AppTextStyles.body.copyWith(color: c.textSecondary))],
          if (shown != null) ...[
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: OutboxGroupCard(
                  group: OutboxGroup(record: shown.record, photos: [...?group?.photos]),
                  progress: progress,
                  sent: [
                    for (final p in first?.photos ?? const <OutboxData>[])
                      if (!open.contains(p.id)) ?_payload(p, 'localPath'),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (done || failed)
            PrimaryButton(label: l10n.done, onPressed: () => Navigator.pop(context))
          else
            SecondaryButton(label: l10n.sendInBackground, onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
