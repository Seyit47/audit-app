import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'core/settings/app_settings.dart';
import 'core/sync/background_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final permission = await Geolocator.checkPermission();
  await registerBackgroundSync();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      initialLocationGrantedProvider.overrideWithValue(permission == LocationPermission.always || permission == LocationPermission.whileInUse),
    ],
    child: const AuditApp(),
  ));
}
