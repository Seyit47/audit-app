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
import '../../../../core/format/phone.dart';

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

  @override
  void initState() {
    super.initState();
    final api = ref.read(adminApiProvider);
    api.regions().then((r) {
      if (mounted) setState(() => _regions = r);
    }, onError: (_) {});
    api.nextAgentCode().then((code) {
      if (mounted && _code.text.isEmpty) _code.text = code;
    }, onError: (_) {});
  }

  @override
  void dispose() {
    for (final c in [_name, _code, _phone, _whatsapp, _notes, _visits, _audits]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      tmPhone(_phone.text, mobile: true) != null &&
      _regionId != null &&
      (_whatsapp.text.trim().isEmpty || tmPhone(_whatsapp.text, mobile: true) != null) &&
      (int.tryParse(_visits.text) ?? 0) >= 1 &&
      (int.tryParse(_audits.text) ?? -1) >= 0;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final visits = int.parse(_visits.text);
    final audits = int.parse(_audits.text);
    if (audits > visits) return setState(() => _error = l10n.planError);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final res = await ref.read(adminApiProvider).createAgent({
        'fullName': _name.text.trim(),
        if (_code.text.trim().isNotEmpty) 'code': _code.text.trim(),
        'phone': tmPhone(_phone.text, mobile: true)!,
        if (_whatsapp.text.trim().isNotEmpty) 'whatsappPhone': tmPhone(_whatsapp.text, mobile: true)!,
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
      if (mounted) {
        setState(() {
          _saving = false;
          _error = l10n.saveFailed;
        });
      }
    }
  }

  Future<void> _showPassword(String password) {
    final l10n = AppLocalizations.of(context);
    return showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      title: Text(l10n.agentCreated),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tempPassword),
          const SizedBox(height: 12),
          SelectableText(
            password,
            style: const TextStyle(fontFamily: AppTextStyles.mono, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: (dialog) => [
        AppDialogAction(
          label: MaterialLocalizations.of(dialog).copyButtonLabel,
          onPressed: () => Clipboard.setData(ClipboardData(text: password)),
        ),
        AppDialogAction(label: l10n.done, primary: true, onPressed: () => Navigator.pop(dialog)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    const gap = SizedBox(height: 22);
    // Save's enabled state follows the fields.
    void touch(String _) => setState(() {});
    // Each field reports what is wrong once the user has changed it (Flutter's Form, onUserInteraction).
    String? required(String v) => v.trim().isEmpty ? l10n.fieldRequired : null;
    String? mobile(String v) => tmPhone(v, mobile: true) == null ? l10n.phoneMobileInvalid : null;
    String? plan(String v, {int min = 1}) {
      final n = int.tryParse(v.trim());
      return n == null || n < min || n > 100 ? l10n.planRange : null;
    }

    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: l10n.addSalesmanTitle),
            Expanded(
              child: Form(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    AppTextFormField(
                      label: l10n.fullName,
                      required: true,
                      controller: _name,
                      validator: required,
                      hint: l10n.fullNameHint,
                      textInputAction: TextInputAction.next,
                      onChanged: touch,
                    ),
                    gap,
                    AppTextFormField(label: l10n.employeeCode, controller: _code, onChanged: touch),
                    gap,
                    AppTextFormField(
                      label: l10n.phoneNumber,
                      required: true,
                      controller: _phone,
                      validator: (v) => required(v) ?? mobile(v),
                      hint: l10n.phoneHint,
                      keyboardType: TextInputType.phone,
                      inputFormatters: const [TmPhoneFormatter()],
                      onChanged: touch,
                    ),
                    gap,
                    AppTextFormField(
                      label: l10n.whatsapp,
                      controller: _whatsapp,
                      validator: (v) => v.trim().isEmpty ? null : mobile(v),
                      hint: l10n.phoneHint,
                      keyboardType: TextInputType.phone,
                      inputFormatters: const [TmPhoneFormatter()],
                      onChanged: touch,
                    ),
                    gap,
                    AppTextFormField(label: l10n.routeNotes, controller: _notes, hint: l10n.routeNotesHint, minLines: 3, maxLines: 5, maxLength: 2000),
                    gap,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextFormField(
                            label: l10n.visitPlan,
                            required: true,
                            controller: _visits,
                            validator: plan,
                            keyboardType: TextInputType.number,
                            onChanged: touch,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextFormField(
                            label: l10n.auditPlan,
                            required: true,
                            controller: _audits,
                            dependsOn: [_visits],
                            validator: (v) {
                              final visits = int.tryParse(_visits.text.trim());
                              return plan(v, min: 0) ?? (visits != null && int.parse(v.trim()) > visits ? l10n.planError : null);
                            },
                            keyboardType: TextInputType.number,
                            onChanged: touch,
                          ),
                        ),
                      ],
                    ),
                    gap,
                    AppFormField(
                      label: l10n.regionField,
                      required: true,
                      valid: _regionId != null,
                      child: AppSelect<String>(
                        value: _regionId,
                        hint: l10n.selectRegion,
                        items: [for (final r in _regions) (r['id'] as String, r['name'] as String)],
                        onChanged: (v) => setState(() => _regionId = v),
                      ),
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(label: l10n.save, loading: _saving, onPressed: _valid ? _save : null),
            ),
          ],
        ),
      ),
    );
  }
}
