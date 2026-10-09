// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Аудит';

  @override
  String get homePrimaryBadge => 'Основное действие';

  @override
  String get homeStartAudit => 'Начать аудит';

  @override
  String get homeStartAuditHint => 'Провести проверку\nмагазина';

  @override
  String get homeMyShops => 'Мои магазины';

  @override
  String get homeMyShopsHint => 'Просмотреть список магазинов';

  @override
  String get homeMap => 'Карта';

  @override
  String get homeMapHint => 'Найти магазины на карте';

  @override
  String get homeGallery => 'Галерея';

  @override
  String get homeGalleryHint => 'Фотоотчёты проверок';

  @override
  String get homeShops => 'Магазины';

  @override
  String get homeAgents => 'Агенты';

  @override
  String get homeProducts => 'Продукции';

  @override
  String get syncDone => 'Данные синхронизированы';

  @override
  String get syncRunning => 'Синхронизация…';

  @override
  String get toggleTheme => 'Переключить тему';

  @override
  String get account => 'Аккаунт';

  @override
  String get signOut => 'Выйти';

  @override
  String get loginTitle => 'Вход';

  @override
  String get loginSubtitle => 'Войдите, чтобы начать работу';

  @override
  String get loginLogin => 'Телефон или email';

  @override
  String get loginPassword => 'Пароль';

  @override
  String get loginSubmit => 'Войти';

  @override
  String get errorCredentials => 'Неверный логин или пароль';

  @override
  String get errorDeviceNotBound => 'Аккаунт привязан к другому устройству. Обратитесь к администратору.';

  @override
  String get errorRateLimited => 'Слишком много попыток. Попробуйте через минуту.';

  @override
  String get errorNetwork => 'Нет соединения с сервером';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get permissionTitle => 'Доступ к геолокации';

  @override
  String get permissionBody =>
      'Приложение отмечает визиты в магазины и проверяет, что аудит проходит на месте. Геолокация используется только в рабочее время и не передаётся в нерабочие часы.';

  @override
  String get permissionAllow => 'Разрешить';

  @override
  String get permissionSettings => 'Открыть настройки';

  @override
  String get permissionDenied => 'Без доступа к геолокации аудит недоступен. Разрешите доступ в настройках.';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get retry => 'Повторить';

  @override
  String get homeAgentsHint => 'Просмотреть список агентов';

  @override
  String get homeProductsHint => 'Просмотреть список продукций';

  @override
  String get shopsTitle => 'Магазины';

  @override
  String get add => 'Добавить';

  @override
  String get search => 'Поиск';

  @override
  String get filters => 'Фильтры';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сбросить';

  @override
  String chipAll(int count) {
    return 'Все ($count)';
  }

  @override
  String chipScheduled(int count) {
    return 'Запланирован ($count)';
  }

  @override
  String chipOverdue(int count) {
    return 'Просрочен ($count)';
  }

  @override
  String chipVisited(int count) {
    return 'Пройден ($count)';
  }

  @override
  String chipNotVisited(int count) {
    return 'Назначен ($count)';
  }

  @override
  String get lastVisit => 'Последний визит:';

  @override
  String get never => '—';

  @override
  String get shopsEmpty => 'Магазинов нет';

  @override
  String get filterRegion => 'Регион';

  @override
  String get filterStatus => 'Статус';

  @override
  String fromYou(String distance) {
    return '$distance от вас';
  }

  @override
  String get contactPerson => 'Контакт';

  @override
  String lastVisitDays(String date, int days) {
    return '$date ($days дн. назад)';
  }

  @override
  String lastVisitToday(String time) {
    return 'Сегодня, $time';
  }

  @override
  String get nextVisit => 'Следующий визит:';

  @override
  String nextVisitOverdue(int days) {
    return 'Срочно (просрочен на $days дн.)';
  }

  @override
  String get nextVisitToday => 'Сегодня';

  @override
  String get mapButton => 'Карта';

  @override
  String get auditButton => 'Аудит';

  @override
  String get auditHistory => 'История аудитов';

  @override
  String auditHistoryCount(int count) {
    return 'Всего зафиксировано $count записей';
  }

  @override
  String get violationRecorded => 'Зафиксировано нарушение';

  @override
  String photoMaterials(int count) {
    return 'Фотоматериалы ($count фото)';
  }

  @override
  String get seeAll => 'Смотреть все';

  @override
  String morePhotos(int count) {
    return '+$count фото';
  }

  @override
  String accuracyInside(int meters) {
    return 'Точность $meters метров (в радиусе магазина)';
  }

  @override
  String accuracyOutside(int meters) {
    return 'Точность $meters метров (вне радиуса магазина)';
  }

  @override
  String get visitMissed => 'Пропущен';

  @override
  String get pendingSync => 'Ожидает синхронизации';

  @override
  String get noAudits => 'Аудитов пока нет';

  @override
  String get sortNewest => 'Сначала новые';

  @override
  String get sortOldest => 'Сначала старые';

  @override
  String get shopNotFound => 'Магазин не найден';

  @override
  String get mapSearch => 'Поиск магазина, владельца, телефона…';

  @override
  String get mapAll => 'Все';

  @override
  String mapNotVisited(int count) {
    return 'Не посещённые($count)';
  }

  @override
  String mapVisited(int count) {
    return 'Посещённые($count)';
  }

  @override
  String get mapRecent => 'Недавно';

  @override
  String get myLocation => 'Моё местоположение';

  @override
  String get zoomIn => 'Приблизить карту';

  @override
  String get zoomOut => 'Отдалить карту';

  @override
  String get startAudit => 'Начать Аудит';

  @override
  String get auditOnlyOnSite => 'Начать аудит можно только на территории магазина';

  @override
  String get locating => 'Определяем местоположение…';

  @override
  String get auditTitle => 'Проведение Аудита';

  @override
  String get offlineSaved => 'Офлайн-режим сохранён';

  @override
  String get geoLocating => 'Определение местоположения...';

  @override
  String geoOutside(int meters) {
    return 'Вы вне территории магазина ($meters м)';
  }

  @override
  String geoInaccurate(int meters) {
    return 'Слабый сигнал GPS (точность $meters м)';
  }

  @override
  String get geoUnavailable => 'Местоположение недоступно';

  @override
  String get recheck => 'Проверить заново';

  @override
  String get photoEmptyTitle => 'Фото POSM ещё не сделано';

  @override
  String get photoEmptyHint => 'Сфотографируйте постеры, воблеры, ценники и шелфтокеры в зоне видимости покупателя';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get auditComment => 'Комментарий к аудиту';

  @override
  String get auditCommentHint => 'Напишите замечания или дополнительную информацию о состоянии торговой точки...';

  @override
  String get violationChip => 'Нарушение';

  @override
  String get finishAudit => 'Завершить аудит';

  @override
  String get auditSaved => 'Аудит сохранён. Он отправится при появлении сети.';

  @override
  String photoLimit(int count) {
    return 'Не больше $count фото';
  }

  @override
  String get addShopTitle => 'Добавить Магазин';

  @override
  String get shopName => 'Название магазина';

  @override
  String get shopNameHint => 'Maya shop';

  @override
  String get address => 'Адрес';

  @override
  String get addressHint => 'West Boulevard';

  @override
  String get owner => 'Владелец';

  @override
  String get ownerHint => 'John Doe';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get phoneHint => '+993 62 112233';

  @override
  String get clear => 'Очистить';

  @override
  String get currentLocation => 'Текущее местоположение';

  @override
  String coordsLine(String lat, String lng) {
    return 'Lat: $lat° N, Long: $lng° E';
  }

  @override
  String accuracyLine(int meters) {
    return 'Точность GPS: $meters м';
  }

  @override
  String get storefrontPhoto => 'Фото витрины';

  @override
  String photoCaptured(String size) {
    return 'Фото сделано · $size';
  }

  @override
  String get photoNotTaken => 'Фото ещё не сделано';

  @override
  String get storefrontHint => 'Сфотографируйте фасад и вывеску магазина';

  @override
  String get retake => 'Переснять';

  @override
  String get shopSaved => 'Магазин сохранён и отправлен на проверку';

  @override
  String get galleryTitle => 'Галерея';

  @override
  String get galleryLibrary => 'Медиатека инспекций';

  @override
  String photoCount(int count) {
    return '$count фото';
  }

  @override
  String get cloudUpToDate => 'Облако актуально';

  @override
  String get quickSearch => 'Быстрый поиск';

  @override
  String get filterParams => 'Параметры фильтрации';

  @override
  String get filterDate => 'Дата';

  @override
  String get dateToday => 'Сегодня';

  @override
  String get date7 => '7 дней';

  @override
  String get date30 => '30 дней';

  @override
  String get filterShop => 'Магазин';

  @override
  String todayDate(String date) {
    return 'Сегодня, $date';
  }

  @override
  String relatedPhotos(int count) {
    return 'Связанные фото аудита ($count)';
  }

  @override
  String get noPhotos => 'Фото пока нет';

  @override
  String get searchShop => 'Поиск по магазину';

  @override
  String totalShops(int count) {
    return 'Всего точек: $count';
  }

  @override
  String get sortAZ => 'Сортировка: A-Z';

  @override
  String get sortZA => 'Сортировка: Z-A';

  @override
  String get typeHYPERMARKET => 'Гипермаркет';

  @override
  String get typeSUPERMARKET => 'Супермаркет';

  @override
  String get typeMARKET => 'Маркет';

  @override
  String get typeMINIMARKET => 'Минимаркет';

  @override
  String get typeOTHER => 'Другое';

  @override
  String get statusACTIVE => 'Активен';

  @override
  String get statusPENDING_REVIEW => 'На проверке';

  @override
  String get statusINACTIVE => 'Неактивен';

  @override
  String get agentLabel => 'Агент: ';

  @override
  String get unassigned => 'Не назначен';

  @override
  String auditsTotal(int count) {
    return '$count аудитов всего';
  }

  @override
  String lastVisitShort(String date) {
    return 'Посл. визит: $date';
  }

  @override
  String get details => 'Подробнее';

  @override
  String get callShop => 'Позвонить в магазин';

  @override
  String get navigate => 'В навигаторе';

  @override
  String get loadError => 'Не удалось загрузить. Потяните, чтобы обновить.';

  @override
  String get shopDetailsTitle => 'Детали магазина';

  @override
  String get actions => 'Действия';

  @override
  String get share => 'Поделиться';

  @override
  String get editShop => 'Редактировать точку';

  @override
  String get totalAudits => 'Всего аудитов';

  @override
  String auditsCount(int count) {
    return '$count аудитов';
  }

  @override
  String get lastVisitTitle => 'Крайний визит';

  @override
  String get addressRegion => 'Адрес и регион';

  @override
  String get responsibleAgent => 'Ответственный агент';

  @override
  String get contact => 'Связаться';

  @override
  String get onShift => 'На смене';

  @override
  String get offShift => 'Не на смене';

  @override
  String get photoReports => 'Фотоотчёты аудитов';

  @override
  String get openGallery => 'Открыть галерею';

  @override
  String get geolocation => 'Геолокация объекта';

  @override
  String get agent => 'Агент';

  @override
  String get editShopTitle => 'Редактировать магазин';

  @override
  String get selectAgent => 'Выберите агента';

  @override
  String get saveFailed => 'Не удалось сохранить. Проверьте поля и попробуйте ещё раз.';

  @override
  String get agentsTitle => 'Агенты';

  @override
  String get kpiStaff => 'Всего в штате';

  @override
  String get kpiOnRoute => 'На маршруте';

  @override
  String get kpiAudits => 'Аудиты ТТ';

  @override
  String get kpiPhotos => 'Фотоотчёты';

  @override
  String get people => 'чел.';

  @override
  String get online => 'онлайн';

  @override
  String get sheets => 'листа';

  @override
  String get frames => 'кадров';

  @override
  String onShiftOf(String pct, int total) {
    return '$pct% в смене (из $total)';
  }

  @override
  String ofPool(String pct) {
    return '$pct% пула на линии';
  }

  @override
  String vsPlan(String pct) {
    return '$pct% к плану дня';
  }

  @override
  String validPhotos(String pct) {
    return '$pct% валидных';
  }

  @override
  String locations(int count) {
    return 'Локации: $count';
  }

  @override
  String photosShort(int count) {
    return 'Фото:$count';
  }

  @override
  String lastActivity(String when) {
    return 'Активность: $when';
  }

  @override
  String get noActivity => 'Нет активности';

  @override
  String get callAgent => 'Позвонить агенту';

  @override
  String get agentsEmpty => 'Агентов нет';

  @override
  String get agentDetailsTitle => 'Детали агента';

  @override
  String get exportPdfXls => 'PDF/XLS';

  @override
  String get exportPdf => 'Отчёт PDF';

  @override
  String get exportXls => 'Отчёт Excel';

  @override
  String get exportFailed => 'Не удалось сформировать отчёт';

  @override
  String get sectorLabel => 'Сектор: ';

  @override
  String onlineGps(int meters) {
    return 'В сети (GPS активен, ±$metersм)';
  }

  @override
  String get offlineSince => 'Не в сети';

  @override
  String updatedAgo(String when) {
    return 'Обновлено $when';
  }

  @override
  String get kpiAllAudits => 'Аудиты за всё время';

  @override
  String get checklists => 'чек-листов';

  @override
  String get kpiShopPlan => 'План магазинов';

  @override
  String get outlets => 'точек';

  @override
  String get kpiVisited => 'Посещено';

  @override
  String ofOutlets(int total, String pct) {
    return 'из $total ($pct%)';
  }

  @override
  String get kpiPhotosAll => 'Фотографий';

  @override
  String get routeTracking => 'Маршрут и трекинг';

  @override
  String hereNow(String name) {
    return '$name (сейчас здесь)';
  }

  @override
  String get checkpointHistory => 'История чекпоинтов';

  @override
  String pointsCount(int count) {
    return '$count точек';
  }

  @override
  String get stopDONE => 'Выполнен';

  @override
  String get stopMISSED => 'Пропущен';

  @override
  String get stopIN_PROGRESS => 'В процессе';

  @override
  String get stopPLANNED => 'План';

  @override
  String get syncingData => 'Синхронизация данных...';

  @override
  String get plannedVisit => 'Плановый визит';

  @override
  String get visitHistory => 'История визитов';

  @override
  String updatedAt(String time) {
    return 'Обновлено в $time';
  }

  @override
  String durationMin(int minutes) {
    return '($minutes мин)';
  }

  @override
  String get statusDone => 'Завершён';

  @override
  String morePhotosOpen(int count) {
    return '+$count фото';
  }

  @override
  String get addSalesmanTitle => 'Добавить агента';

  @override
  String get fullName => 'ФИО';

  @override
  String get fullNameHint => 'Например, Довлет Оразов';

  @override
  String get employeeCode => 'Табельный номер / Код';

  @override
  String get generateCode => 'Сгенерировать';

  @override
  String get whatsapp => 'Доп. телефон / WhatsApp';

  @override
  String get routeNotes => 'Заметки / график маршрута';

  @override
  String get routeNotesHint => 'Краткое описание сектора или дней маршрута';

  @override
  String get visitPlan => 'План визитов в день (магазинов)';

  @override
  String get auditPlan => 'Чек-листы / аудиты в день';

  @override
  String get regionField => 'Регион / территория продаж';

  @override
  String get selectRegion => 'Выберите регион';

  @override
  String get workStatus => 'Статус активности сотрудника';

  @override
  String get onLeave => 'В отпуске';

  @override
  String get agentCreated => 'Агент добавлен';

  @override
  String get tempPassword => 'Временный пароль (показывается один раз, передайте его агенту):';

  @override
  String get done => 'Готово';

  @override
  String get planError => 'План аудитов не может превышать план визитов';

  @override
  String get productsTitle => 'Продукции';

  @override
  String get productsEmpty => 'Продукции нет';

  @override
  String get addProductTitle => 'Добавить продукт';

  @override
  String get sku => 'Артикул (SKU)';

  @override
  String get productName => 'Название продукта';

  @override
  String get category => 'Категория';

  @override
  String get selectCategory => 'Выберите категорию';

  @override
  String get brand => 'Бренд';

  @override
  String get retailPrice => 'Розничная цена';

  @override
  String get description => 'Описание';

  @override
  String get productImage => 'Изображение продукта';

  @override
  String get productImageHint => 'PNG или JPG, до 5 МБ';

  @override
  String get statusDRAFT => 'Черновик';

  @override
  String get productStatus => 'Статус';

  @override
  String get stockTracked => 'Учитывать остатки';

  @override
  String get stockQty => 'Остаток на складе';

  @override
  String get minStockAlert => 'Минимальный остаток';

  @override
  String coverage(String pct) {
    return 'Покрытие: $pct%';
  }

  @override
  String locationsShort(int count) {
    return 'Точек: $count';
  }

  @override
  String price(String price) {
    return '$price TMT';
  }

  @override
  String get skuConflict => 'Такой артикул уже есть';

  @override
  String get pickOnMap => 'Указать на карте';

  @override
  String get mapPickTitle => 'Расположение магазина';

  @override
  String get mapPickHint => 'Перемещайте карту, чтобы поставить метку на вход в магазин';

  @override
  String get mapPickDone => 'Выбрать эту точку';

  @override
  String get pickedOnMap => 'Точка выбрана на карте';

  @override
  String visitDuration(int minutes) {
    return 'Длительность: $minutes мин';
  }

  @override
  String notInShopRadius(String name, String distance) {
    return 'Вы не в радиусе магазина. Ближайший: $name, $distance';
  }
}
