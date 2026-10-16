import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/home_header.dart';

/// Why location is needed, shown before the OS dialogs (approved exception A9). Built from the
/// Home background, the add-shop icon tile style and the primary button.
class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  bool _denied = false;

  /// Granted, but only "approximate" (Android 12+): ~1–3 km, useless for audits.
  bool _approximate = false;

  Future<void> _request() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    // Background tracking needs "always": Android asks for it as a second step.
    if (permission == LocationPermission.whileInUse) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      setState(() => _denied = true);
      await Geolocator.openAppSettings();
      return;
    }
    var granted = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    final approximate = granted && await isApproximate();
    if (approximate) {
      // Precise location is a switch in the app's permission settings.
      if (_approximate) await Geolocator.openAppSettings();
      granted = false;
    }
    setState(() {
      _denied = !granted && !approximate;
      _approximate = approximate;
    });
    ref.read(locationGrantedProvider.notifier).set(granted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
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
                  if (_approximate) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.permissionPrecise,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(color: c.error),
                    ),
                  ],
                  if (_denied) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.permissionDenied,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(color: c.error),
                    ),
                  ],
                  const Spacer(),
                  PrimaryButton(label: _denied || _approximate ? l10n.permissionSettings : l10n.permissionAllow, onPressed: _request),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Whether location is granted only approximately (Android 12+ "Approximate"): audits need precise.
Future<bool> isApproximate() async {
  try {
    return await Geolocator.getLocationAccuracy() == LocationAccuracyStatus.reduced;
  } catch (_) {
    return false;
  }
}
