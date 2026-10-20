import '../../../core/l10n/app_localizations.dart';

String shopTypeLabel(AppLocalizations l10n, String? type) => switch (type) {
  'HYPERMARKET' => l10n.typeHYPERMARKET,
  'SUPERMARKET' => l10n.typeSUPERMARKET,
  'MARKET' => l10n.typeMARKET,
  'MINIMARKET' => l10n.typeMINIMARKET,
  _ => l10n.typeOTHER,
};

String shopStatusLabel(AppLocalizations l10n, String? status) => switch (status) {
  'ACTIVE' => l10n.statusACTIVE,
  'PENDING_REVIEW' => l10n.statusPENDING_REVIEW,
  _ => l10n.statusINACTIVE,
};

/// A shop's agents on a card: one or two in full, more as "A, B +N" (the details screen lists them all).
String agentNames(List<String> names) => names.length <= 2 ? names.join(', ') : '${names.take(2).join(', ')} +${names.length - 2}';
