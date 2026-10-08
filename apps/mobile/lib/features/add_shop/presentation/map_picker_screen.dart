import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/map_view.dart';
import '../../audit/domain/geofence.dart';

/// Where exactly the shop is: the map moves under a fixed pin; "Выбрать эту точку" returns the point under it.
///
/// For an agent the point must stay within [limitMeters] of their GPS position ([limitFrom]), so a shop is
/// still registered where the agent actually is; an admin picks freely.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, required this.start, this.limitFrom, this.limitMeters});

  final (double, double) start;
  final (double, double)? limitFrom;
  final double? limitMeters;

  static Future<(double, double)?> open(BuildContext context, {required (double, double) start, (double, double)? limitFrom, double? limitMeters}) =>
      Navigator.of(context).push<(double, double)>(
        MaterialPageRoute(
          builder: (_) => MapPickerScreen(start: start, limitFrom: limitFrom, limitMeters: limitMeters),
        ),
      );

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _map = AppMapController();
  late (double, double) _point = widget.start;

  int? get _tooFarBy {
    final from = widget.limitFrom;
    final limit = widget.limitMeters;
    if (from == null || limit == null) return null;
    final d = distanceMeters(from.$1, from.$2, _point.$1, _point.$2);
    return d > limit ? d.round() : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final tooFar = _tooFarBy;
    return Scaffold(
      backgroundColor: c.mainBg,
      body: Stack(
        children: [
          AppMapView(
            markers: const [],
            controller: _map,
            initial: widget.start,
            initialZoom: 17,
            onCameraIdle: () {
              final center = _map.center;
              if (center != null) setState(() => _point = center);
            },
          ),
          // The pin's tip marks the middle of the map.
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -22),
                child: Icon(Icons.location_on, size: 44, color: c.accent),
              ),
            ),
          ),
          SafeArea(
            child: Container(
              color: c.mainBg.withValues(alpha: 0.92),
              child: AppTopBar(title: l10n.mapPickTitle, onBack: () => Navigator.of(context).pop()),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 16 + MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tooFar != null ? l10n.mapPickTooFar(tooFar, widget.limitMeters!.round()) : l10n.mapPickHint,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(color: tooFar != null ? c.error : c.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.coordsLine(_point.$1.toStringAsFixed(5), _point.$2.toStringAsFixed(5)),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: AppTextStyles.mono, fontSize: 12, height: 16.5 / 12, color: c.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(label: l10n.mapPickDone, onPressed: tooFar != null ? null : () => Navigator.of(context).pop(_point)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
