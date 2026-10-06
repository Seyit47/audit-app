// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Audit';

  @override
  String get homePrimaryBadge => 'Main action';

  @override
  String get homeStartAudit => 'Start audit';

  @override
  String get homeStartAuditHint => 'Inspect a\nshop';

  @override
  String get homeMyShops => 'My shops';

  @override
  String get homeMyShopsHint => 'View the list of shops';

  @override
  String get homeMap => 'Map';

  @override
  String get homeMapHint => 'Find shops on the map';

  @override
  String get homeGallery => 'Gallery';

  @override
  String get homeGalleryHint => 'Audit photo reports';

  @override
  String get homeShops => 'Shops';

  @override
  String get homeAgents => 'Agents';

  @override
  String get homeProducts => 'Products';

  @override
  String get syncDone => 'Data synced';

  @override
  String get syncRunning => 'Syncing…';

  @override
  String get toggleTheme => 'Switch theme';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Sign in to start working';

  @override
  String get loginLogin => 'Phone or email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get errorCredentials => 'Wrong login or password';

  @override
  String get errorDeviceNotBound =>
      'This account is bound to another device. Contact your administrator.';

  @override
  String get errorRateLimited => 'Too many attempts. Try again in a minute.';

  @override
  String get errorNetwork => 'No connection to the server';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get permissionTitle => 'Location access';

  @override
  String get permissionBody =>
      'The app records shop visits and checks that audits happen on site. Location is used only during working hours and is not sent outside them.';

  @override
  String get permissionAllow => 'Allow';

  @override
  String get permissionSettings => 'Open settings';

  @override
  String get permissionDenied =>
      'Audits need location access. Allow it in the settings.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get homeAgentsHint => 'View the list of agents';

  @override
  String get homeProductsHint => 'View the list of products';
}
