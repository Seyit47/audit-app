import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/format/formatters.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/settings/remote_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/adaptive.dart';
import '../../../core/widgets/bottom_sheet_card.dart';
import '../../../core/widgets/buttons.dart';
import '../../audit/domain/geofence.dart';
import '../../audit/presentation/audit_controller.dart';

/// "Начать аудит": a sheet that looks for the agent's GPS fix (radar rings around their dot), then draws the
/// nearest shop's audit radius with the agent placed to scale. Pops with the shop id when the agent stands
/// inside a radius and taps Start.
Future<String?> showStartAuditSheet(BuildContext context) =>
    // Like the filter sheet: a Cupertino modal popup on iOS, a Material modal bottom sheet on Android.
    context.isCupertino
    ? showCupertinoModalPopup<String>(
        context: context,
        builder: (_) => const Material(type: MaterialType.transparency, child: _StartAuditSheet()),
      )
    : showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        showDragHandle: false,
        backgroundColor: Colors.transparent,
        builder: (_) => const _StartAuditSheet(),
      );

enum _Phase { locating, inside, outside, inaccurate, unavailable, noShops }

class _StartAuditSheet extends ConsumerStatefulWidget {
  const _StartAuditSheet();

  @override
  ConsumerState<_StartAuditSheet> createState() => _StartAuditSheetState();
}

class _StartAuditSheetState extends ConsumerState<_StartAuditSheet> with TickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  late final _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  _Phase _phase = _Phase.locating;
  Fix? _fix;
  NearestShop<Shop>? _hit;

  /// Every shop whose radius the agent is in, nearest first; two or more let the agent pick.
  List<NearestShop<Shop>> _inRange = const [];

  @override
  void initState() {
    super.initState();
    _locate();
  }

  @override
  void dispose() {
    _fixes?.cancel();
    _pulse.dispose();
    _reveal.dispose();
    super.dispose();
  }

  StreamSubscription<Fix?>? _fixes;

  Future<void> _locate() async {
    await _fixes?.cancel();
    setState(() => _phase = _Phase.locating);
    _reveal.reset();
    final db = ref.read(databaseProvider);
    final config = ref.read(remoteConfigProvider).value ?? const RemoteConfig();
    final shops = await (db.select(db.shops)..where((s) => s.status.equals('ACTIVE'))).get();
    // The radar shows for a moment at least, so an instant answer doesn't make the sheet flicker.
    final shown = Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    // The last known position at once, then the GPS fix the moment it answers: each one updates the sheet.
    _fixes = ref
        .read(locatorProvider)
        .watch()
        .asyncMap((fix) async {
          await shown;
          return fix;
        })
        .listen((fix) {
          if (!mounted) return;
          final hit = fix == null ? null : nearestShop(shops, fix, lat: (s) => s.lat, lng: (s) => s.lng, radiusM: (s) => s.auditRadiusM);
          final inRange = fix == null ? <NearestShop<Shop>>[] : shopsInRange(shops, fix, lat: (s) => s.lat, lng: (s) => s.lng, radiusM: (s) => s.auditRadiusM);
          final first = _phase == _Phase.locating;
          setState(() {
            _fix = fix;
            _hit = hit;
            _inRange = inRange;
            _phase = switch (fix) {
              null => _Phase.unavailable,
              _ when fix.accuracyM > config.minGpsAccuracyM => _Phase.inaccurate,
              _ when hit == null => _Phase.noShops,
              _ => hit.inside ? _Phase.inside : _Phase.outside,
            };
          });
          if (first) _reveal.forward();
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final hit = _hit;
    final (message, tone) = switch (_phase) {
      _Phase.locating => (l10n.geoLocating, c.textSecondary),
      _Phase.inside when _inRange.length > 1 => (l10n.chooseShop, c.textPrimary),
      _Phase.inside => (l10n.insideShopRadius(hit!.shop.name), c.success),
      _Phase.outside => (l10n.notInShopRadius(hit!.shop.name, distance(context, hit.meters)), c.error),
      _Phase.inaccurate => (l10n.geoInaccurate(_fix!.accuracyM.round()), c.error),
      _Phase.unavailable => (l10n.geoUnavailable, c.error),
      _Phase.noShops => (l10n.shopsEmpty, c.textSecondary),
    };
    return BottomSheetCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.homeStartAudit,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox.square(
              dimension: 240,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _RadarPainter(
                    pulse: _pulse,
                    reveal: CurvedAnimation(parent: _reveal, curve: Curves.easeOutBack),
                    fix: _phase == _Phase.locating ? null : _fix,
                    shop: _phase == _Phase.locating ? null : hit,
                    accent: c.accent,
                    inside: c.success,
                    outside: c.error,
                    ring: c.border,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              message,
              key: ValueKey(message),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: tone),
            ),
          ),
          const SizedBox(height: 20),
          if (_phase == _Phase.inside && _inRange.length > 1)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 232),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _inRange.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _ShopChoice(
                  name: _inRange[i].shop.name,
                  distance: distance(context, _inRange[i].meters),
                  onTap: () => Navigator.pop(context, _inRange[i].shop.id),
                ),
              ),
            )
          else if (_phase == _Phase.inside)
            PrimaryButton(label: l10n.startAudit, onPressed: () => Navigator.pop(context, hit!.shop.id))
          else
            PrimaryButton(label: l10n.recheck, loading: _phase == _Phase.locating, onPressed: _phase == _Phase.locating ? null : _locate),
          const SizedBox(height: 12),
          SecondaryButton(label: l10n.cancel, onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

/// Before a fix: rings spreading from the agent's dot like a GPS signal. After: the shop's audit radius grows
/// in around the shop, and the agent's dot (with its accuracy halo, still pulsing) sits where they stand,
/// both fitted into the square.
class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.pulse,
    required this.reveal,
    required this.fix,
    required this.shop,
    required this.accent,
    required this.inside,
    required this.outside,
    required this.ring,
  }) : super(repaint: Listenable.merge([pulse, reveal]));

  final Animation<double> pulse;
  final Animation<double> reveal;
  final Fix? fix;
  final NearestShop<Shop>? shop;
  final Color accent;
  final Color inside;
  final Color outside;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final half = size.shortestSide / 2;
    // Faint range rings, like a radar screen.
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..color = ring
      ..strokeWidth = 1;
    for (final f in [0.33, 0.66, 1.0]) {
      canvas.drawCircle(center, half * f - 1, grid);
    }

    final fix = this.fix;
    final shop = this.shop;
    if (fix == null || shop == null) {
      _signal(canvas, center, half, fix == null ? accent : outside);
      _dot(canvas, center, fix == null ? accent : outside);
      return;
    }

    // Meters east/north of the shop, then a scale that fits the radius and the agent with a margin.
    final s = shop.shop;
    final east = (fix.lng - s.lng) * 111320 * math.cos(s.lat * math.pi / 180);
    final north = (fix.lat - s.lat) * 110540;
    final r = s.auditRadiusM.toDouble();
    final acc = math.min(fix.accuracyM, r);
    final minX = math.min(-r, east - acc), maxX = math.max(r, east + acc);
    final minY = math.min(-r, north - acc), maxY = math.max(r, north + acc);
    final scale = (half - 18) / math.max(maxX - minX, maxY - minY) * 2;
    final mid = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    Offset toScreen(double x, double y) => center + Offset(x - mid.dx, -(y - mid.dy)) * scale;

    final t = reveal.value;
    final shopAt = toScreen(0, 0);
    final userAt = toScreen(east, north);
    final tone = shop.inside ? inside : outside;
    final radius = r * scale * t;

    canvas.drawCircle(shopAt, radius, Paint()..color = accent.withValues(alpha: 0.12));
    canvas.drawCircle(
      shopAt,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.7),
    );
    // Shop pin.
    canvas.drawCircle(shopAt, 7 * t, Paint()..color = accent);
    canvas.drawCircle(shopAt, 3 * t, Paint()..color = Colors.white);

    if (!shop.inside) _dashed(canvas, userAt, shopAt, tone.withValues(alpha: 0.8 * t));
    canvas.drawCircle(userAt, acc * scale, Paint()..color = tone.withValues(alpha: 0.12));
    _signal(canvas, userAt, 28, tone);
    _dot(canvas, userAt, tone);
  }

  void _signal(Canvas canvas, Offset at, double reach, Color color) {
    for (var k = 0; k < 3; k++) {
      final phase = (pulse.value + k / 3) % 1;
      canvas.drawCircle(
        at,
        8 + (reach - 8) * phase,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: 0.45 * (1 - phase)),
      );
    }
  }

  void _dot(Canvas canvas, Offset at, Color color) {
    canvas.drawCircle(at, 10, Paint()..color = Colors.white);
    canvas.drawCircle(at, 7, Paint()..color = color);
  }

  void _dashed(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final length = (to - from).distance;
    if (length == 0) return;
    final dir = (to - from) / length;
    for (var d = 0.0; d < length; d += 10) {
      canvas.drawLine(from + dir * d, from + dir * math.min(d + 5, length), paint);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.fix != fix || old.shop != shop || old.accent != accent;
}

/// One shop to choose when several are in range: name, distance, and a chevron; tapping starts its audit.
class _ShopChoice extends StatelessWidget {
  const _ShopChoice({required this.name, required this.distance, required this.onTap});

  final String name;
  final String distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Text(distance, style: AppTextStyles.caption.copyWith(color: c.textSecondary)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: c.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
