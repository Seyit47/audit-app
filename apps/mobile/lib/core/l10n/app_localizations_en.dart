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

  @override
  String get addShopTitle => 'Add shop';

  @override
  String get shopName => 'Shop name';

  @override
  String get shopNameHint => 'Maya shop';

  @override
  String get address => 'Address';

  @override
  String get addressHint => 'West Boulevard';

  @override
  String get owner => 'Owner';

  @override
  String get ownerHint => 'John Doe';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneHint => '+993 62 112233';

  @override
  String get clear => 'Clear';

  @override
  String get currentLocation => 'Current location';

  @override
  String coordsLine(String lat, String lng) {
    return 'Lat: $lat° N, Long: $lng° E';
  }

  @override
  String accuracyLine(int meters) {
    return 'GPS accuracy: $meters m';
  }

  @override
  String get storefrontPhoto => 'Storefront Photo';

  @override
  String photoCaptured(String size) {
    return 'Photo captured · $size';
  }

  @override
  String get photoNotTaken => 'No photo yet';

  @override
  String get storefrontHint => 'Photograph the shop front and its sign';

  @override
  String get retake => 'Retake';

  @override
  String get shopSaved => 'Shop saved and sent for review';

  @override
  String get galleryTitle => 'Gallery';

  @override
  String get galleryLibrary => 'Inspection library';

  @override
  String photoCount(int count) {
    return '$count photos';
  }

  @override
  String get cloudUpToDate => 'Cloud up to date';

  @override
  String get quickSearch => 'Quick search';

  @override
  String get filterParams => 'Filter options';

  @override
  String get filterDate => 'Date';

  @override
  String get dateToday => 'Today';

  @override
  String get date7 => '7 days';

  @override
  String get date30 => '30 days';

  @override
  String get filterShop => 'Shop';

  @override
  String todayDate(String date) {
    return 'Today, $date';
  }

  @override
  String relatedPhotos(int count) {
    return 'Related audit photos ($count)';
  }

  @override
  String get noPhotos => 'No photos yet';

  @override
  String get searchShop => 'Search by shop';

  @override
  String totalShops(int count) {
    return 'Total outlets: $count';
  }

  @override
  String get sortAZ => 'Sort: A-Z';

  @override
  String get sortZA => 'Sort: Z-A';

  @override
  String get typeHYPERMARKET => 'Hypermarket';

  @override
  String get typeSUPERMARKET => 'Supermarket';

  @override
  String get typeMARKET => 'Market';

  @override
  String get typeMINIMARKET => 'Minimarket';

  @override
  String get typeOTHER => 'Other';

  @override
  String get statusACTIVE => 'Active';

  @override
  String get statusPENDING_REVIEW => 'Pending review';

  @override
  String get statusINACTIVE => 'Inactive';

  @override
  String get agentLabel => 'Salesman: ';

  @override
  String get unassigned => 'Unassigned';

  @override
  String auditsTotal(int count) {
    return '$count audits in total';
  }

  @override
  String lastVisitShort(String date) {
    return 'Last visit: $date';
  }

  @override
  String get details => 'Details';

  @override
  String get callShop => 'Call the shop';

  @override
  String get navigate => 'Navigate';

  @override
  String get loadError => 'Could not load. Pull to refresh.';

  @override
  String get shopDetailsTitle => 'Shop Details';

  @override
  String get actions => 'Actions';

  @override
  String get share => 'Share';

  @override
  String get editShop => 'Edit shop';

  @override
  String get totalAudits => 'Total audits';

  @override
  String auditsCount(int count) {
    return '$count audits';
  }

  @override
  String get lastVisitTitle => 'Last visit';

  @override
  String get addressRegion => 'Address & region';

  @override
  String get responsibleAgent => 'Responsible salesman';

  @override
  String get contact => 'Contact';

  @override
  String get onShift => 'On shift';

  @override
  String get offShift => 'Off shift';

  @override
  String get photoReports => 'Audit photo reports';

  @override
  String get openGallery => 'Open gallery';

  @override
  String get geolocation => 'Shop location';

  @override
  String get agent => 'Salesman';

  @override
  String get editShopTitle => 'Edit shop';

  @override
  String get selectAgent => 'Select a salesman';

  @override
  String get saveFailed => 'Could not save. Check the fields and try again.';

  @override
  String get agentsTitle => 'Salesmen';

  @override
  String get kpiStaff => 'Total staff';

  @override
  String get kpiOnRoute => 'On route';

  @override
  String get kpiAudits => 'Outlet audits';

  @override
  String get kpiPhotos => 'Photo reports';

  @override
  String get people => 'people';

  @override
  String get online => 'online';

  @override
  String get sheets => 'checklists';

  @override
  String get frames => 'photos';

  @override
  String onShiftOf(String pct, int total) {
    return '$pct% on shift (of $total)';
  }

  @override
  String ofPool(String pct) {
    return '$pct% of the pool on the line';
  }

  @override
  String vsPlan(String pct) {
    return '$pct% vs the daily plan';
  }

  @override
  String validPhotos(String pct) {
    return '$pct% valid';
  }

  @override
  String locations(int count) {
    return 'Locations: $count';
  }

  @override
  String photosShort(int count) {
    return 'Photos:$count';
  }

  @override
  String lastActivity(String when) {
    return 'Activity: $when';
  }

  @override
  String get noActivity => 'No activity yet';

  @override
  String get callAgent => 'Call the salesman';

  @override
  String get agentsEmpty => 'No salesmen';

  @override
  String get agentDetailsTitle => 'Salesman details';

  @override
  String get exportPdfXls => 'PDF/XLS';

  @override
  String get exportPdf => 'PDF report';

  @override
  String get exportXls => 'Excel report';

  @override
  String get exportFailed => 'Could not build the report';

  @override
  String get sectorLabel => 'Sector: ';

  @override
  String onlineGps(int meters) {
    return 'Online (GPS on, ±$meters m)';
  }

  @override
  String get offlineSince => 'Offline';

  @override
  String updatedAgo(String when) {
    return 'Updated $when';
  }

  @override
  String get kpiAllAudits => 'All-time audits';

  @override
  String get checklists => 'checklists';

  @override
  String get kpiShopPlan => 'Shop plan';

  @override
  String get outlets => 'outlets';

  @override
  String get kpiVisited => 'Visited';

  @override
  String ofOutlets(int total, String pct) {
    return 'of $total ($pct%)';
  }

  @override
  String get kpiPhotosAll => 'Photos';

  @override
  String get routeTracking => 'Route and tracking';

  @override
  String hereNow(String name) {
    return '$name (here now)';
  }

  @override
  String get checkpointHistory => 'Checkpoint history';

  @override
  String pointsCount(int count) {
    return '$count stops';
  }

  @override
  String get stopDONE => 'Done';

  @override
  String get stopMISSED => 'Missed';

  @override
  String get stopIN_PROGRESS => 'In progress';

  @override
  String get stopPLANNED => 'Planned';

  @override
  String get syncingData => 'Syncing data...';

  @override
  String get plannedVisit => 'Planned visit';

  @override
  String get visitHistory => 'Visit history';

  @override
  String updatedAt(String time) {
    return 'Updated at $time';
  }

  @override
  String durationMin(int minutes) {
    return '($minutes min)';
  }

  @override
  String get statusDone => 'Completed';

  @override
  String morePhotosOpen(int count) {
    return '+$count photos';
  }

  @override
  String get addSalesmanTitle => 'Add salesman';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameHint => 'e.g. Dovlet Orazov';

  @override
  String get employeeCode => 'Employee number / Code';

  @override
  String get generateCode => 'Generate';

  @override
  String get whatsapp => 'Additional phone / WhatsApp';

  @override
  String get routeNotes => 'Notes / Route schedule';

  @override
  String get routeNotesHint => 'Short description of the sector or route days';

  @override
  String get visitPlan => 'Daily visit plan (shops)';

  @override
  String get auditPlan => 'Checklists / audits per day';

  @override
  String get regionField => 'Region / Sales territory';

  @override
  String get selectRegion => 'Select a region';

  @override
  String get workStatus => 'Employee activity status';

  @override
  String get onLeave => 'On leave';

  @override
  String get agentCreated => 'Salesman added';

  @override
  String get tempPassword =>
      'Temporary password (shown once, pass it to the salesman):';

  @override
  String get done => 'Done';

  @override
  String get planError => 'The audit plan cannot exceed the visit plan';

  @override
  String get productsTitle => 'Products';

  @override
  String get productsEmpty => 'No products';

  @override
  String get addProductTitle => 'Add product';

  @override
  String get sku => 'SKU';

  @override
  String get productName => 'Product name';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get brand => 'Brand';

  @override
  String get retailPrice => 'Retail price';

  @override
  String get description => 'Description';

  @override
  String get productImage => 'Product image';

  @override
  String get productImageHint => 'PNG or JPG, up to 5 MB';

  @override
  String get statusDRAFT => 'Draft';

  @override
  String get productStatus => 'Status';

  @override
  String get stockTracked => 'Track stock';

  @override
  String get stockQty => 'Stock quantity';

  @override
  String get minStockAlert => 'Minimum stock alert';

  @override
  String coverage(String pct) {
    return 'Coverage: $pct%';
  }

  @override
  String locationsShort(int count) {
    return 'Outlets: $count';
  }

  @override
  String price(String price) {
    return '$price TMT';
  }

  @override
  String get skuConflict => 'This SKU already exists';
}
