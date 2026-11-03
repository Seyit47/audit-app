import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/location/location_grant.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/home_header.dart';

/// Why location is needed, shown before the OS dialogs (approved exception A9), and until it is allowed
/// "all the time" and precise. Built from the Home background, the add-shop icon tile style and the
/// primary button.
class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  /// What the last attempt ended with (null before the first tap).
  LocationGrant? _grant;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back from the OS settings: read the result without asking again.
    _lifecycle = AppLifecycleListener(onResume: _recheck);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _recheck() async {
    final grant = await readLocationGrant();
    if (!mounted) return;
    if (_grant != null) setState(() => _grant = grant);
    ref.read(locationGrantedProvider.notifier).set(grant == LocationGrant.granted);
  }

  Future<void> _request() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    // Background tracking needs "all the time": Android 10 asks in a second dialog, Android 11+ opens the
    // app's location settings for it.
    if (permission == LocationPermission.whileInUse) permission = await Geolocator.requestPermission();
    final allowed = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    final grant = grantOf(permission, approximate: allowed && await isApproximate());
    // Refused for good, or the same shortfall as last time: only the app's settings can change it ("all the
    // time" and "precise" are switches there).
    if (grant == LocationGrant.deniedForever || (grant != LocationGrant.granted && grant == _grant)) await Geolocator.openAppSettings();
    if (!mounted) return;
    setState(() => _grant = grant);
    ref.read(locationGrantedProvider.notifier).set(grant == LocationGrant.granted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final problem = switch (_grant) {
      LocationGrant.whileInUse => l10n.permissionAlways,
      LocationGrant.approximate => l10n.permissionPrecise,
      LocationGrant.denied || LocationGrant.deniedForever => l10n.permissionDenied,
      LocationGrant.granted || null => null,
    };
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: HomeGlow()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.accent6, shape: BoxShape.circle),
                    child: AppIcon('home-map', width: 19.5, height: 19.5, color: c.accent),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.permissionTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTextStyles.family,
                      fontSize: 20,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.permissionBody,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                  if (problem != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      problem,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(color: c.error),
                    ),
                  ],
                  const Spacer(),
                  PrimaryButton(label: _grant == null || _grant == LocationGrant.denied ? l10n.permissionAllow : l10n.permissionSettings, onPressed: _request),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
