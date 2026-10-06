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
}
