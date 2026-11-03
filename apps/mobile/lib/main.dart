import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/location/location_grant.dart';
import 'core/router/app_router.dart';
import 'core/settings/app_settings.dart';
import 'core/sync/background_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Edge-to-edge like native Android apps: the app draws behind transparent status and navigation bars
  // (screens keep their content clear with SafeArea).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // A widget that fails to build shows a small neutral notice instead of the red (debug) or grey (release)
  // error box, and an uncaught async error is logged instead of ending the app.
  ErrorWidget.builder = (details) => const _BrokenPart();
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };
  final prefs = await SharedPreferences.getInstance();
  final granted = await readLocationGrant() == LocationGrant.granted;
  await registerBackgroundSync();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // "While using the app" or approximate location counts as not granted: the permission screen asks
        // for "all the time" and precise, which background tracking needs.
        initialLocationGrantedProvider.overrideWithValue(granted),
      ],
      child: const AuditApp(),
    ),
  );
}

class _BrokenPart extends StatelessWidget {
  const _BrokenPart();

  @override
  Widget build(BuildContext context) {
    final ru = PlatformDispatcher.instance.locale.languageCode != 'en';
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 18, color: Color(0xFF9E9EAB)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              ru ? 'Не удалось показать этот блок' : 'This part could not be shown',
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9EAB)),
            ),
          ),
        ],
      ),
    );
  }
}
