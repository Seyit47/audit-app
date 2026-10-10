// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkmen (`tk`).
class AppLocalizationsTk extends AppLocalizations {
  AppLocalizationsTk([String locale = 'tk']) : super(locale);

  @override
  String get appTitle => 'Audit';

  @override
  String get homePrimaryBadge => 'Esasy hereket';

  @override
  String get homeStartAudit => 'Audite başla';

  @override
  String get homeStartAuditHint => 'Dükany barlamak';

  @override
  String get homeMyShops => 'Meniň dükanlarym';

  @override
  String get homeMyShopsHint => 'Dükanlaryň sanawyny görmek';

  @override
  String get homeMap => 'Karta';

  @override
  String get homeMapHint => 'Dükanlary kartada tapmak';

  @override
  String get homeGallery => 'Galereýa';

  @override
  String get homeGalleryHint => 'Auditleriň surat hasabatlary';

  @override
  String get homeShops => 'Dükanlar';

  @override
  String get homeAgents => 'Agentler';

  @override
  String get homeProducts => 'Önümler';

  @override
  String get syncDone => 'Maglumatlar sinhronlandy';

  @override
  String get syncRunning => 'Sinhronlanýar…';

  @override
  String get toggleTheme => 'Temany çalyş';

  @override
  String get account => 'Hasap';

  @override
  String get signOut => 'Çyk';

  @override
  String get loginTitle => 'Giriş';

  @override
  String get loginSubtitle => 'Işe başlamak üçin giriň';

  @override
  String get loginLogin => 'Telefon ýa-da e-poçta';

  @override
  String get loginPassword => 'Açar söz';

  @override
  String get loginSubmit => 'Gir';

  @override
  String get errorCredentials => 'Login ýa-da açar söz nädogry';

  @override
  String get errorDeviceNotBound => 'Bu hasap başga enjama baglanan. Administratora ýüz tutuň.';

  @override
  String get errorRateLimited => 'Synanyşyk köp boldy. Bir minutdan gaýtadan synanyşyň.';

  @override
  String get errorNetwork => 'Serwer bilen aragatnaşyk ýok';

  @override
  String get errorGeneric => 'Bir zat nädogry boldy. Gaýtadan synanyşyň.';

  @override
  String get permissionTitle => 'Ýerleşişe rugsat';

  @override
  String get permissionBody =>
      'Programma dükanlara saparlary hasaba alýar we auditleriň ýerinde geçirilýändigini barlaýar. Ýerleşiş diňe iş wagtynda ulanylýar we ondan daşary iberilmeýär.';

  @override
  String get permissionAllow => 'Rugsat ber';

  @override
  String get permissionSettings => 'Sazlamalary aç';

  @override
  String get permissionDenied => 'Auditler üçin ýerleşişe rugsat gerek. Ony sazlamalarda beriň.';

  @override
  String get cancel => 'Ýatyr';

  @override
  String get save => 'Ýatda sakla';

  @override
  String get retry => 'Gaýtadan synanyş';

  @override
  String get homeAgentsHint => 'Agentleriň sanawyny görmek';

  @override
  String get homeProductsHint => 'Önümleriň sanawyny görmek';

  @override
  String get shopsTitle => 'Dükanlar';

  @override
  String get add => 'Goş';

  @override
  String get search => 'Gözleg';

  @override
  String get filters => 'Süzgüçler';

  @override
  String get apply => 'Ulan';

  @override
  String get reset => 'Arassala';

  @override
  String chipAll(int count) {
    return 'Ählisi ($count)';
  }

  @override
  String chipScheduled(int count) {
    return 'Meýilleşdirilen ($count)';
  }

  @override
  String chipOverdue(int count) {
    return 'Gijikdirilen ($count)';
  }

  @override
  String chipVisited(int count) {
    return 'Barlanan ($count)';
  }

  @override
  String chipNotVisited(int count) {
    return 'Bellenen ($count)';
  }

  @override
  String get lastVisit => 'Soňky sapar:';

  @override
  String get never => '—';

  @override
  String get shopsEmpty => 'Dükan ýok';

  @override
  String get filterRegion => 'Sebit';

  @override
  String get filterStatus => 'Ýagdaý';

  @override
  String fromYou(String distance) {
    return 'Sizden $distance';
  }

  @override
  String get contactPerson => 'Habarlaşmak üçin';

  @override
  String lastVisitDays(String date, int days) {
    return '$date ($days gün öň)';
  }

  @override
  String lastVisitToday(String time) {
    return 'Şu gün, $time';
  }

  @override
  String get nextVisit => 'Indiki sapar:';

  @override
  String nextVisitOverdue(int days) {
    return 'Gyssagly ($days gün gijikdi)';
  }

  @override
  String get nextVisitToday => 'Şu gün';

  @override
  String get mapButton => 'Karta';

  @override
  String get auditButton => 'Audit';

  @override
  String get auditHistory => 'Auditleriň taryhy';

  @override
  String auditHistoryCount(int count) {
    return 'Jemi $count ýazgy';
  }

  @override
  String get violationRecorded => 'Bozulma bellenildi';

  @override
  String photoMaterials(int count) {
    return 'Suratlar ($count)';
  }

  @override
  String get seeAll => 'Ählisini gör';

  @override
  String morePhotos(int count) {
    return '+$count surat';
  }

  @override
  String accuracyInside(int meters) {
    return 'Takyklygy $meters m (dükanyň radiusynyň içinde)';
  }

  @override
  String accuracyOutside(int meters) {
    return 'Takyklygy $meters m (dükanyň radiusyndan daşarda)';
  }

  @override
  String get visitMissed => 'Galdyryldy';

  @override
  String get pendingSync => 'Sinhronlanmagyna garaşýar';

  @override
  String get noAudits => 'Häzirlikçe audit ýok';

  @override
  String get sortNewest => 'Ilki täzeler';

  @override
  String get sortOldest => 'Ilki könüler';

  @override
  String get shopNotFound => 'Dükan tapylmady';

  @override
  String get mapSearch => 'Dükan, eýesi, telefon gözle...';

  @override
  String get mapAll => 'Ählisi';

  @override
  String mapNotVisited(int count) {
    return 'Barlanmadyk ($count)';
  }

  @override
  String mapVisited(int count) {
    return 'Barlanan ($count)';
  }

  @override
  String get mapRecent => 'Soňkular';

  @override
  String get myLocation => 'Meniň ýerim';

  @override
  String get zoomIn => 'Ýakynlaşdyr';

  @override
  String get zoomOut => 'Daşlaşdyr';

  @override
  String get startAudit => 'Audite başla';

  @override
  String get auditOnlyOnSite => 'Audite diňe dükanyň çäginde başlap bolýar';

  @override
  String get locating => 'Ýerleşiş kesgitlenýär…';

  @override
  String get auditTitle => 'Audit';

  @override
  String get offlineSaved => 'Oflaýn ýatda saklandy';

  @override
  String get geoLocating => 'Ýerleşiş kesgitlenýär...';

  @override
  String geoOutside(int meters) {
    return 'Siz dükandan daşarda ($meters m)';
  }

  @override
  String geoInaccurate(int meters) {
    return 'GPS signaly gowşak (takyklygy $meters m)';
  }

  @override
  String get geoUnavailable => 'Ýerleşiş elýeterli däl';

  @override
  String get recheck => 'Gaýtadan barla';

  @override
  String get photoEmptyTitle => 'Häzirlikçe POSM suraty ýok';

  @override
  String get photoEmptyHint => 'Afişalary, wobblerleri, baha bellikleri we tekje bellikleri alyjynyň gözi bilen surata düşüriň';

  @override
  String get takePhoto => 'Surata düşür';

  @override
  String get removePhoto => 'Suraty poz';

  @override
  String get auditComment => 'Audit boýunça teswir';

  @override
  String get auditCommentHint => 'Bellikleri ýa-da söwda nokady barada goşmaça maglumat ýazyň...';

  @override
  String get violationChip => 'Bozulma';

  @override
  String get finishAudit => 'Auditi tamamla';

  @override
  String get auditSaved => 'Audit ýatda saklandy. Aragatnaşyk bolanda iberiler.';

  @override
  String photoLimit(int count) {
    return 'Iň köp $count surat';
  }

  @override
  String get addShopTitle => 'Dükan goş';

  @override
  String get shopName => 'Dükanyň ady';

  @override
  String get shopNameHint => 'Maýa dükany';

  @override
  String get address => 'Salgy';

  @override
  String get addressHint => 'Günbatar şaýoly';

  @override
  String get owner => 'Eýesi';

  @override
  String get ownerHint => 'Aman Amanow';

  @override
  String get phoneNumber => 'Telefon belgisi';

  @override
  String get phoneHint => '+993 62 112233';

  @override
  String get clear => 'Arassala';

  @override
  String get currentLocation => 'Häzirki ýerleşiş';

  @override
  String coordsLine(String lat, String lng) {
    return 'Giňlik: $lat° N, Uzaklyk: $lng° E';
  }

  @override
  String accuracyLine(int meters) {
    return 'GPS takyklygy: $meters m';
  }

  @override
  String get storefrontPhoto => 'Fasadyň suraty';

  @override
  String photoCaptured(String size) {
    return 'Surat alyndy · $size';
  }

  @override
  String get photoNotTaken => 'Häzirlikçe surat ýok';

  @override
  String get storefrontHint => 'Dükanyň öňüni we ýazgysyny surata düşüriň';

  @override
  String get retake => 'Gaýtadan düşür';

  @override
  String get shopSaved => 'Dükan ýatda saklandy we barlaga iberildi';

  @override
  String get galleryTitle => 'Galereýa';

  @override
  String get galleryLibrary => 'Barlaglaryň kitaphanasy';

  @override
  String photoCount(int count) {
    return '$count surat';
  }

  @override
  String get cloudUpToDate => 'Bulut täzelendi';

  @override
  String get quickSearch => 'Çalt gözleg';

  @override
  String get filterParams => 'Süzgüç sazlamalary';

  @override
  String get filterDate => 'Sene';

  @override
  String get dateToday => 'Şu gün';

  @override
  String get date7 => '7 gün';

  @override
  String get date30 => '30 gün';

  @override
  String get filterShop => 'Dükan';

  @override
  String todayDate(String date) {
    return 'Şu gün, $date';
  }

  @override
  String relatedPhotos(int count) {
    return 'Auditiň baglanyşykly suratlary ($count)';
  }

  @override
  String get noPhotos => 'Häzirlikçe surat ýok';

  @override
  String get searchShop => 'Dükan boýunça gözleg';

  @override
  String totalShops(int count) {
    return 'Jemi söwda nokady: $count';
  }

  @override
  String get sortAZ => 'Tertip: A-Z';

  @override
  String get sortZA => 'Tertip: Z-A';

  @override
  String get typeHYPERMARKET => 'Gipermarket';

  @override
  String get typeSUPERMARKET => 'Supermarket';

  @override
  String get typeMARKET => 'Market';

  @override
  String get typeMINIMARKET => 'Minimarket';

  @override
  String get typeOTHER => 'Beýleki';

  @override
  String get statusACTIVE => 'Işjeň';

  @override
  String get statusPENDING_REVIEW => 'Barlagda';

  @override
  String get statusINACTIVE => 'Işjeň däl';

  @override
  String get agentLabel => 'Agent: ';

  @override
  String get unassigned => 'Bellenmedik';

  @override
  String auditsTotal(int count) {
    return 'Jemi $count audit';
  }

  @override
  String lastVisitShort(String date) {
    return 'Soňky sapar: $date';
  }

  @override
  String get details => 'Jikme-jik';

  @override
  String get callShop => 'Dükana jaň et';

  @override
  String get navigate => 'Ugur';

  @override
  String get loadError => 'Ýükläp bolmady. Täzelemek üçin aşak çekiň.';

  @override
  String get shopDetailsTitle => 'Dükan barada';

  @override
  String get actions => 'Hereketler';

  @override
  String get share => 'Paýlaş';

  @override
  String get editShop => 'Dükany üýtget';

  @override
  String get totalAudits => 'Jemi audit';

  @override
  String auditsCount(int count) {
    return '$count audit';
  }

  @override
  String get lastVisitTitle => 'Soňky sapar';

  @override
  String get addressRegion => 'Salgy we sebit';

  @override
  String get responsibleAgent => 'Jogapkär agent';

  @override
  String get contact => 'Habarlaşmak';

  @override
  String get onShift => 'Smenada';

  @override
  String get offShift => 'Smenada däl';

  @override
  String get photoReports => 'Auditleriň surat hasabatlary';

  @override
  String get openGallery => 'Galereýany aç';

  @override
  String get geolocation => 'Dükanyň ýerleşişi';

  @override
  String get agent => 'Agent';

  @override
  String get editShopTitle => 'Dükany üýtget';

  @override
  String get selectAgent => 'Agenti saýlaň';

  @override
  String get saveFailed => 'Ýatda saklap bolmady. Meýdançalary barlap, gaýtadan synanyşyň.';

  @override
  String get agentsTitle => 'Agentler';

  @override
  String get kpiStaff => 'Jemi işgär';

  @override
  String get kpiOnRoute => 'Ugurda';

  @override
  String get kpiAudits => 'Söwda nokatlarynyň auditi';

  @override
  String get kpiPhotos => 'Surat hasabatlary';

  @override
  String get people => 'adam';

  @override
  String get online => 'ulgamda';

  @override
  String get sheets => 'çek-list';

  @override
  String get frames => 'surat';

  @override
  String onShiftOf(String pct, int total) {
    return '$pct% smenada ($total-dan)';
  }

  @override
  String ofPool(String pct) {
    return 'Umumy sanyň $pct% ugurda';
  }

  @override
  String vsPlan(String pct) {
    return 'Günüň meýilnamasynyň $pct%';
  }

  @override
  String validPhotos(String pct) {
    return '$pct% dogry';
  }

  @override
  String locations(int count) {
    return 'Nokatlar: $count';
  }

  @override
  String photosShort(int count) {
    return 'Surat:$count';
  }

  @override
  String lastActivity(String when) {
    return 'Işjeňlik: $when';
  }

  @override
  String get noActivity => 'Häzirlikçe işjeňlik ýok';

  @override
  String get callAgent => 'Agente jaň et';

  @override
  String get agentsEmpty => 'Agent ýok';

  @override
  String get agentDetailsTitle => 'Agent barada';

  @override
  String get exportPdfXls => 'PDF/XLS';

  @override
  String get exportPdf => 'PDF hasabat';

  @override
  String get exportXls => 'Excel hasabat';

  @override
  String get exportFailed => 'Hasabaty düzüp bolmady';

  @override
  String get sectorLabel => 'Sektor: ';

  @override
  String onlineGps(int meters) {
    return 'Ulgamda (GPS işjeň, ±$meters m)';
  }

  @override
  String get offlineSince => 'Ulgamda däl';

  @override
  String updatedAgo(String when) {
    return 'Täzelendi $when';
  }

  @override
  String get kpiAllAudits => 'Ähli wagtdaky auditler';

  @override
  String get checklists => 'çek-list';

  @override
  String get kpiShopPlan => 'Dükan meýilnamasy';

  @override
  String get outlets => 'söwda nokady';

  @override
  String get kpiVisited => 'Barlanan';

  @override
  String ofOutlets(int total, String pct) {
    return '$total-dan ($pct%)';
  }

  @override
  String get kpiPhotosAll => 'Suratlar';

  @override
  String get routeTracking => 'Ugur we yzarlamak';

  @override
  String hereNow(String name) {
    return '$name (häzir şu ýerde)';
  }

  @override
  String get checkpointHistory => 'Barlag nokatlarynyň taryhy';

  @override
  String pointsCount(int count) {
    return '$count nokat';
  }

  @override
  String get stopDONE => 'Ýerine ýetirildi';

  @override
  String get stopMISSED => 'Galdyryldy';

  @override
  String get stopIN_PROGRESS => 'Dowam edýär';

  @override
  String get stopPLANNED => 'Meýilnama';

  @override
  String get syncingData => 'Maglumatlar sinhronlanýar...';

  @override
  String get plannedVisit => 'Meýilleşdirilen sapar';

  @override
  String get visitHistory => 'Saparlaryň taryhy';

  @override
  String updatedAt(String time) {
    return '$time-da täzelendi';
  }

  @override
  String durationMin(int minutes) {
    return '($minutes min)';
  }

  @override
  String get statusDone => 'Tamamlandy';

  @override
  String morePhotosOpen(int count) {
    return '+$count surat';
  }

  @override
  String get addSalesmanTitle => 'Agent goş';

  @override
  String get fullName => 'F.A.A.';

  @override
  String get fullNameHint => 'Mysal üçin, Döwlet Orazow';

  @override
  String get employeeCode => 'Tabel belgisi / Kod';

  @override
  String get generateCode => 'Döret';

  @override
  String get whatsapp => 'Goşmaça telefon / WhatsApp';

  @override
  String get routeNotes => 'Bellikler / Ugur tertibi';

  @override
  String get routeNotesHint => 'Sektoryň ýa-da ugur günleriniň gysgaça beýany';

  @override
  String get visitPlan => 'Gündelik sapar meýilnamasy (dükanlar)';

  @override
  String get auditPlan => 'Günde çek-list / audit';

  @override
  String get regionField => 'Sebit / Satuw territoriýasy';

  @override
  String get selectRegion => 'Sebiti saýlaň';

  @override
  String get workStatus => 'Işgäriň işjeňlik ýagdaýy';

  @override
  String get onLeave => 'Rugsatda';

  @override
  String get agentCreated => 'Agent goşuldy';

  @override
  String get tempPassword => 'Wagtlaýyn açar söz (bir gezek görkezilýär, ony agente beriň):';

  @override
  String get done => 'Taýýar';

  @override
  String get planError => 'Audit meýilnamasy sapar meýilnamasyndan köp bolup bilmez';

  @override
  String get productsTitle => 'Önümler';

  @override
  String get productsEmpty => 'Önüm ýok';

  @override
  String get addProductTitle => 'Önüm goş';

  @override
  String get sku => 'Artikul';

  @override
  String get productName => 'Önümiň ady';

  @override
  String get category => 'Kategoriýa';

  @override
  String get selectCategory => 'Kategoriýany saýlaň';

  @override
  String get brand => 'Brend';

  @override
  String get retailPrice => 'Bölek satuw bahasy';

  @override
  String get description => 'Beýany';

  @override
  String get productImage => 'Önümiň suraty';

  @override
  String get productImageHint => 'PNG ýa-da JPG, 5 MB çenli';

  @override
  String get statusDRAFT => 'Garalama';

  @override
  String get productStatus => 'Ýagdaý';

  @override
  String get stockTracked => 'Galyndyny hasaba al';

  @override
  String get stockQty => 'Galyndy mukdary';

  @override
  String get minStockAlert => 'Iň az galyndy duýduryşy';

  @override
  String coverage(String pct) {
    return 'Gurşaw: $pct%';
  }

  @override
  String locationsShort(int count) {
    return 'Nokatlar: $count';
  }

  @override
  String price(String price) {
    return '$price TMT';
  }

  @override
  String get skuConflict => 'Bu artikul eýýäm bar';

  @override
  String get pickOnMap => 'Kartada saýla';

  @override
  String get mapPickTitle => 'Dükanyň ýerleşişi';

  @override
  String get mapPickHint => 'Belligi dükanyň girelgesine goýmak üçin kartany süýşüriň';

  @override
  String get mapPickDone => 'Bu nokady ulan';

  @override
  String get pickedOnMap => 'Kartada saýlandy';

  @override
  String visitDuration(int minutes) {
    return 'Dowamlylygy: $minutes min';
  }

  @override
  String notInShopRadius(String name, String distance) {
    return 'Siz hiç bir dükanyň radiusynda däl. Iň ýakyny: $name, $distance';
  }

  @override
  String get fieldRequired => 'Hökmany meýdança';

  @override
  String get phoneMobileInvalid => 'Mobil belgi: +993 6X XXXXXX (ýa-da 71, 72)';

  @override
  String get phoneInvalid => 'Türkmen belgisi: +993 we 8 san';

  @override
  String get planRange => '1-den 100-e çenli';

  @override
  String get priceInvalid => 'Bahany giriziň, mysal üçin 185.00';

  @override
  String get countInvalid => 'Bitin san, 0 ýa-da köp';

  @override
  String get shopNotActive => 'Dükan barlagda — administrator tassyklandan soň auditler açylar';
}
