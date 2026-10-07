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

  @override
  String get shopsTitle => 'Shops';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get filters => 'Filters';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String chipAll(int count) {
    return 'All ($count)';
  }

  @override
  String chipScheduled(int count) {
    return 'Scheduled ($count)';
  }

  @override
  String chipOverdue(int count) {
    return 'Overdue ($count)';
  }

  @override
  String chipVisited(int count) {
    return 'Visited ($count)';
  }

  @override
  String chipNotVisited(int count) {
    return 'Assigned ($count)';
  }

  @override
  String get lastVisit => 'Last visit:';

  @override
  String get never => '—';

  @override
  String get shopsEmpty => 'No shops';

  @override
  String get filterRegion => 'Region';

  @override
  String get filterStatus => 'Status';

  @override
  String fromYou(String distance) {
    return '$distance from you';
  }

  @override
  String get contactPerson => 'Contact';

  @override
  String lastVisitDays(String date, int days) {
    return '$date ($days days ago)';
  }

  @override
  String lastVisitToday(String time) {
    return 'Today, $time';
  }

  @override
  String get nextVisit => 'Next visit:';

  @override
  String nextVisitOverdue(int days) {
    return 'Urgent ($days days overdue)';
  }

  @override
  String get nextVisitToday => 'Today';

  @override
  String get mapButton => 'Map';

  @override
  String get auditButton => 'Audit';

  @override
  String get auditHistory => 'Audit history';

  @override
  String auditHistoryCount(int count) {
    return '$count records in total';
  }

  @override
  String get violationRecorded => 'Violation recorded';

  @override
  String photoMaterials(int count) {
    return 'Photos ($count)';
  }

  @override
  String get seeAll => 'See all';

  @override
  String morePhotos(int count) {
    return '+$count photos';
  }

  @override
  String accuracyInside(int meters) {
    return 'Accuracy $meters m (inside the shop radius)';
  }

  @override
  String accuracyOutside(int meters) {
    return 'Accuracy $meters m (outside the shop radius)';
  }

  @override
  String get visitMissed => 'Missed';

  @override
  String get pendingSync => 'Waiting to sync';

  @override
  String get noAudits => 'No audits yet';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get shopNotFound => 'Shop not found';

  @override
  String get mapSearch => 'Search shop, owner, phone...';

  @override
  String get mapAll => 'All';

  @override
  String mapNotVisited(int count) {
    return 'Not visited ($count)';
  }

  @override
  String mapVisited(int count) {
    return 'Visited ($count)';
  }

  @override
  String get mapRecent => 'Recent';

  @override
  String get myLocation => 'My location';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get startAudit => 'Start audit';

  @override
  String get auditOnlyOnSite =>
      'You can start the audit only on the shop\'s premises';

  @override
  String get locating => 'Locating…';

  @override
  String get auditTitle => 'Audit';

  @override
  String get offlineSaved => 'Saved offline';

  @override
  String get geoLocating => 'Determining location...';

  @override
  String geoOutside(int meters) {
    return 'You are outside the shop ($meters m)';
  }

  @override
  String geoInaccurate(int meters) {
    return 'Weak GPS signal (accuracy $meters m)';
  }

  @override
  String get geoUnavailable => 'Location unavailable';

  @override
  String get recheck => 'Check again';

  @override
  String get photoEmptyTitle => 'No POSM photo yet';

  @override
  String get photoEmptyHint =>
      'Photograph posters, wobblers, price tags and shelf talkers in the shopper\'s view';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get auditComment => 'Audit comment';

  @override
  String get auditCommentHint =>
      'Write remarks or more details about the outlet...';

  @override
  String get violationChip => 'Violation';

  @override
  String get finishAudit => 'Finish audit';

  @override
  String get auditSaved => 'Audit saved. It will be sent when online.';

  @override
  String photoLimit(int count) {
    return 'At most $count photos';
  }
}
