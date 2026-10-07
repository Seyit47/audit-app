import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/filter_chips.dart';
import '../../../../core/widgets/form_field.dart';
import '../../data/admin_api.dart';
import '../../../../core/widgets/adaptive.dart';

/// Mobile Add Salesman (approved exception A7): the fields of Figma `495:3932`, laid out with the
/// mobile form components of `252:25542`. Saves with `POST /agents` and shows the temporary
/// password once.
class AgentFormScreen extends ConsumerStatefulWidget {
  const AgentFormScreen({super.key});

  @override
  ConsumerState<AgentFormScreen> createState() => _AgentFormScreenState();
}

class _AgentFormScreenState extends ConsumerState<AgentFormScreen> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _notes = TextEditingController();
  final _visits = TextEditingController(text: '25');
  final _audits = TextEditingController(text: '20');
  String? _regionId;
  String _status = 'ACTIVE';
  List<Json> _regions = const [];
  bool _saving = false;
  String? _error;

  static final _phoneRe = RegExp(r'^\+?[0-9 ()-]{6,20}$');

  @override
  void initState() {
    super.initState();
    final api = ref.read(adminApiProvider);
    api.regions().then((r) { if (mounted) setState(() => _regions = r); }, onError: (_) {});
    api.nextAgentCode().then((code) { if (mounted && _code.text.isEmpty) _code.text = code; }, onError: (_) {});
  }

  @override
  void dispose() {
    for (final c in [_name, _code, _phone, _whatsapp, _notes, _visits, _audits]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty && _phoneRe.hasMatch(_phone.text.trim()) && _regionId != null &&
      (_whatsapp.text.trim().isEmpty || _phoneRe.hasMatch(_whatsapp.text.trim())) &&
      (int.tryParse(_visits.text) ?? 0) >= 1 && (int.tryParse(_audits.text) ?? -1) >= 0;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final visits = int.parse(_visits.text);
    final audits = int.parse(_audits.text);
    if (audits > visits) return setState(() => _error = l10n.planError);
    setState(() { _saving = true; _error = null; });
    try {
      final res = await ref.read(adminApiProvider).createAgent({
        'fullName': _name.text.trim(),
        if (_code.text.trim().isNotEmpty) 'code': _code.text.trim(),
        'phone': _phone.text.trim(),
        if (_whatsapp.text.trim().isNotEmpty) 'whatsappPhone': _whatsapp.text.trim(),
        'regionId': _regionId,
        if (_notes.text.trim().isNotEmpty) 'routeNotes': _notes.text.trim(),
        'dailyVisitPlan': visits,
        'dailyAuditPlan': audits,
        'workStatus': _status,
      });
      if (!mounted) return;
      await _showPassword(res['temporaryPassword'] as String);
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) setState(() { _saving = false; _error = l10n.saveFailed; });
    }
  }

  Future<void> _showPassword(String password) {
    final l10n = AppLocalizations.of(context);
    return showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      title: Text(l10n.agentCreated),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.tempPassword),
        const SizedBox(height: 12),
        SelectableText(password, style: const TextStyle(fontFamily: AppTextStyles.mono, fontSize: 20, fontWeight: FontWeight.w600)),
      ]),
      actions: (dialog) => [
        AppDialogAction(label: MaterialLocalizations.of(dialog).copyButtonLabel, onPressed: () => Clipboard.setData(ClipboardData(text: password))),
        AppDialogAction(label: l10n.done, primary: true, onPressed: () => Navigator.pop(dialog)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    void touch(String _) => setState(() {});
    const gap = SizedBox(height: 22);

    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(children: [
          AppTopBar(title: l10n.addSalesmanTitle),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
              AppFormField(label: l10n.fullName, required: true, valid: _name.text.trim().isNotEmpty,
                  child: AppTextInput(controller: _name, hint: l10n.fullNameHint, textInputAction: TextInputAction.next, onChanged: touch)),
              gap,
              AppFormField(label: l10n.employeeCode, child: AppTextInput(controller: _code, onChanged: touch)),
              gap,
              AppFormField(label: l10n.phoneNumber, required: true, valid: _phoneRe.hasMatch(_phone.text.trim()),
                  child: AppTextInput(controller: _phone, hint: l10n.phoneHint, keyboardType: TextInputType.phone, onChanged: touch)),
              gap,
              AppFormField(label: l10n.whatsapp, child: AppTextInput(controller: _whatsapp, hint: l10n.phoneHint, keyboardType: TextInputType.phone, onChanged: touch)),
              gap,
              AppFormField(
                label: l10n.routeNotes,
                child: AppTextInput(controller: _notes, hint: l10n.routeNotesHint, minLines: 3, maxLines: 5, maxLength: 2000),
              ),
              gap,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: AppFormField(label: l10n.visitPlan, required: true,
                    child: AppTextInput(controller: _visits, keyboardType: TextInputType.number, onChanged: touch))),
                const SizedBox(width: 12),
                Expanded(child: AppFormField(label: l10n.auditPlan, required: true,
                    child: AppTextInput(controller: _audits, keyboardType: TextInputType.number, onChanged: touch))),
              ]),
              gap,
              AppFormField(
                label: l10n.regionField, required: true, valid: _regionId != null,
                child: AppSelect<String>(value: _regionId, hint: l10n.selectRegion, items: [for (final r in _regions) (r['id'] as String, r['name'] as String)], onChanged: (v) => setState(() => _regionId = v)),
              ),
              gap,
              AppFormField(
                label: l10n.workStatus,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChips<String>(
                    selected: _status,
                    onSelected: (v) => setState(() => _status = v),
                    options: [ChipOption('ACTIVE', l10n.statusACTIVE), ChipOption('ON_LEAVE', l10n.onLeave)],
                  ),
                ),
              ),
              if (_error != null) ...[const SizedBox(height: 16), Text(_error!, style: AppTextStyles.caption.copyWith(color: c.error))],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: PrimaryButton(label: l10n.save, loading: _saving, onPressed: _valid ? _save : null),
          ),
        ]),
      ),
    );
  }
}
