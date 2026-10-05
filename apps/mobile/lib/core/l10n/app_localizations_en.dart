// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Retail audit';

  @override
  String get navHome => 'Home';

  @override
  String get navShops => 'Shops';

  @override
  String get navMap => 'Map';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navAgents => 'Agents';

  @override
  String get roleAgent => 'Agent';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get rolePickerTitle => 'Choose a role (development mode)';

  @override
  String get switchRole => 'Switch role';

  @override
  String get signInPlaceholder => 'Sign-in is coming soon.';

  @override
  String get statusChecking => 'Connecting to server...';

  @override
  String statusConnected(String version) {
    return 'Backend connected · v$version';
  }

  @override
  String get statusUnreachable =>
      'Service is temporarily unavailable. Check your connection.';

  @override
  String get retry => 'Retry';

  @override
  String get updateRequired =>
      'An app update is required. Please install the latest version.';

  @override
  String get comingSoon => 'This section is coming soon.';
}
