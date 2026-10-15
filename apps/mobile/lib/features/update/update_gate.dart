import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/adaptive.dart';
import 'app_update.dart';

/// Looks for a newer app on start and whenever the app returns to the foreground (at most every 30 minutes,
/// every time while a required update is pending) and offers it. Wraps the app's screens.
class UpdateGate extends ConsumerStatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends ConsumerState<UpdateGate> with WidgetsBindingObserver {
  static const _every = Duration(minutes: 30);

  DateTime? _checkedAt;
  bool _requiredPending = false;
  bool _showing = false;

  /// "Later" for this build: not offered again until the app restarts.
  int? _postponed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final at = _checkedAt;
    if (_showing || (!_requiredPending && at != null && DateTime.now().difference(at) < _every)) return;
    _checkedAt = DateTime.now();
    final update = await ref.read(updateServiceProvider).check();
    _requiredPending = update?.required ?? false;
    if (update == null || (!update.required && update.build == _postponed)) return;
    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted || _showing) return;
    _showing = true;
    final later = await showUpdateDialog(context, update, ref.read(updateServiceProvider));
    _showing = false;
    if (later) _postponed = update.build;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The update dialog (also from the Updates screen); true when the agent chose "Later".
Future<bool> showUpdateDialog(BuildContext context, AppUpdate update, UpdateService service) async =>
    await showAdaptiveDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UpdateDialog(update: update, service: service),
    ) ??
    false;

enum _Phase { offer, downloading, permission, ready, failed }

/// Offer → download with progress → (allow installs from this app, once) → the system installer.
/// Pops true for "Later".
class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.update, required this.service});

  final AppUpdate update;
  final UpdateService service;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> with WidgetsBindingObserver {
  _Phase _phase = _Phase.offer;
  double _progress = 0;
  String? _path;
  CancelToken? _cancel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancel?.cancel();
    super.dispose();
  }

  // Back from the "Install unknown apps" setting: install if it was allowed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _phase == _Phase.permission) _install();
  }

  Future<void> _download() async {
    setState(() {
      _phase = _Phase.downloading;
      _progress = 0;
    });
    final cancel = _cancel = CancelToken();
    try {
      final path = await widget.service.download(
        widget.update,
        cancel: cancel,
        onProgress: (f) {
          if (mounted) setState(() => _progress = f.clamp(0, 1));
        },
      );
      _path = path;
      await _install();
    } catch (_) {
      if (mounted && !cancel.isCancelled) setState(() => _phase = _Phase.failed);
    }
  }

  Future<void> _install() async {
    final path = _path;
    if (path == null) return;
    if (!await widget.service.canInstall()) {
      if (mounted) setState(() => _phase = _Phase.permission);
      return;
    }
    if (mounted) setState(() => _phase = _Phase.ready);
    await widget.service.install(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final u = widget.update;
    final canLater = !u.required;
    final mb = (u.sizeBytes / 1048576).toStringAsFixed(1);

    final Widget content = switch (_phase) {
      _Phase.offer => Text([u.required ? l10n.updateRequired : l10n.updateOptional, if (u.notes.isNotEmpty) u.notes, l10n.updateSize(mb)].join('\n\n')),
      _Phase.downloading => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.updateDownloading((_progress * 100).round())),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: _progress, minHeight: 6, borderRadius: BorderRadius.circular(3), color: c.accent),
        ],
      ),
      _Phase.permission => Text(l10n.updatePermission),
      _Phase.ready => Text(l10n.updateReady),
      _Phase.failed => Text(l10n.updateFailed, style: AppTextStyles.body.copyWith(color: c.error)),
    };

    final actions = <Widget>[
      if (canLater && _phase != _Phase.ready)
        AppDialogAction(
          label: l10n.updateLater,
          onPressed: () {
            _cancel?.cancel();
            Navigator.pop(context, true);
          },
        ),
      switch (_phase) {
        _Phase.offer => AppDialogAction(label: l10n.updateNow, primary: true, onPressed: _download),
        _Phase.downloading => const SizedBox.shrink(),
        _Phase.permission => AppDialogAction(label: l10n.permissionSettings, primary: true, onPressed: widget.service.openInstallSettings),
        _Phase.ready => AppDialogAction(label: l10n.updateInstall, primary: true, onPressed: _install),
        _Phase.failed => AppDialogAction(label: l10n.retry, primary: true, onPressed: _download),
      },
    ];

    return PopScope(
      canPop: false,
      child: AlertDialog.adaptive(title: Text(l10n.updateTitle(u.version)), content: content, actions: actions),
    );
  }
}
