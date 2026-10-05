// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Аудит торговых точек';

  @override
  String get navHome => 'Главная';

  @override
  String get navShops => 'Магазины';

  @override
  String get navMap => 'Карта';

  @override
  String get navGallery => 'Галерея';

  @override
  String get navAgents => 'Агенты';

  @override
  String get roleAgent => 'Агент';

  @override
  String get roleAdmin => 'Администратор';

  @override
  String get rolePickerTitle => 'Выберите роль (режим разработки)';

  @override
  String get switchRole => 'Сменить роль';

  @override
  String get signInPlaceholder => 'Вход в систему скоро появится.';

  @override
  String get statusChecking => 'Подключение к серверу...';

  @override
  String statusConnected(String version) {
    return 'Сервер подключён · v$version';
  }

  @override
  String get statusUnreachable =>
      'Сервис временно недоступен. Проверьте подключение.';

  @override
  String get retry => 'Повторить';

  @override
  String get updateRequired =>
      'Требуется обновление приложения. Установите последнюю версию.';

  @override
  String get comingSoon => 'Этот раздел скоро появится.';
}
