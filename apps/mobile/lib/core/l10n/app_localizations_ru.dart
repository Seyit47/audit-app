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
  String get errorDeviceNotBound =>
      'Аккаунт привязан к другому устройству. Обратитесь к администратору.';

  @override
  String get errorRateLimited =>
      'Слишком много попыток. Попробуйте через минуту.';

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
  String get permissionDenied =>
      'Без доступа к геолокации аудит недоступен. Разрешите доступ в настройках.';

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
  String get auditOnlyOnSite =>
      'Начать аудит можно только на территории магазина';

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
  String get photoEmptyHint =>
      'Сфотографируйте постеры, воблеры, ценники и шелфтокеры в зоне видимости покупателя';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get auditComment => 'Комментарий к аудиту';

  @override
  String get auditCommentHint =>
      'Напишите замечания или дополнительную информацию о состоянии торговой точки...';

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
}
