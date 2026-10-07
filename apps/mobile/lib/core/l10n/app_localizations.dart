import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аудит'**
  String get appTitle;

  /// No description provided for @homePrimaryBadge.
  ///
  /// In ru, this message translates to:
  /// **'Основное действие'**
  String get homePrimaryBadge;

  /// No description provided for @homeStartAudit.
  ///
  /// In ru, this message translates to:
  /// **'Начать аудит'**
  String get homeStartAudit;

  /// No description provided for @homeStartAuditHint.
  ///
  /// In ru, this message translates to:
  /// **'Провести проверку\nмагазина'**
  String get homeStartAuditHint;

  /// No description provided for @homeMyShops.
  ///
  /// In ru, this message translates to:
  /// **'Мои магазины'**
  String get homeMyShops;

  /// No description provided for @homeMyShopsHint.
  ///
  /// In ru, this message translates to:
  /// **'Просмотреть список магазинов'**
  String get homeMyShopsHint;

  /// No description provided for @homeMap.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get homeMap;

  /// No description provided for @homeMapHint.
  ///
  /// In ru, this message translates to:
  /// **'Найти магазины на карте'**
  String get homeMapHint;

  /// No description provided for @homeGallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get homeGallery;

  /// No description provided for @homeGalleryHint.
  ///
  /// In ru, this message translates to:
  /// **'Фотоотчёты проверок'**
  String get homeGalleryHint;

  /// No description provided for @homeShops.
  ///
  /// In ru, this message translates to:
  /// **'Магазины'**
  String get homeShops;

  /// No description provided for @homeAgents.
  ///
  /// In ru, this message translates to:
  /// **'Агенты'**
  String get homeAgents;

  /// No description provided for @homeProducts.
  ///
  /// In ru, this message translates to:
  /// **'Продукции'**
  String get homeProducts;

  /// No description provided for @syncDone.
  ///
  /// In ru, this message translates to:
  /// **'Данные синхронизированы'**
  String get syncDone;

  /// No description provided for @syncRunning.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация…'**
  String get syncRunning;

  /// No description provided for @toggleTheme.
  ///
  /// In ru, this message translates to:
  /// **'Переключить тему'**
  String get toggleTheme;

  /// No description provided for @account.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get signOut;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы начать работу'**
  String get loginSubtitle;

  /// No description provided for @loginLogin.
  ///
  /// In ru, this message translates to:
  /// **'Телефон или email'**
  String get loginLogin;

  /// No description provided for @loginPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get loginPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get loginSubmit;

  /// No description provided for @errorCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный логин или пароль'**
  String get errorCredentials;

  /// No description provided for @errorDeviceNotBound.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт привязан к другому устройству. Обратитесь к администратору.'**
  String get errorDeviceNotBound;

  /// No description provided for @errorRateLimited.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Попробуйте через минуту.'**
  String get errorRateLimited;

  /// No description provided for @errorNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Нет соединения с сервером'**
  String get errorNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Попробуйте ещё раз.'**
  String get errorGeneric;

  /// No description provided for @permissionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доступ к геолокации'**
  String get permissionTitle;

  /// No description provided for @permissionBody.
  ///
  /// In ru, this message translates to:
  /// **'Приложение отмечает визиты в магазины и проверяет, что аудит проходит на месте. Геолокация используется только в рабочее время и не передаётся в нерабочие часы.'**
  String get permissionBody;

  /// No description provided for @permissionAllow.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить'**
  String get permissionAllow;

  /// No description provided for @permissionSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get permissionSettings;

  /// No description provided for @permissionDenied.
  ///
  /// In ru, this message translates to:
  /// **'Без доступа к геолокации аудит недоступен. Разрешите доступ в настройках.'**
  String get permissionDenied;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @homeAgentsHint.
  ///
  /// In ru, this message translates to:
  /// **'Просмотреть список агентов'**
  String get homeAgentsHint;

  /// No description provided for @homeProductsHint.
  ///
  /// In ru, this message translates to:
  /// **'Просмотреть список продукций'**
  String get homeProductsHint;

  /// No description provided for @shopsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Магазины'**
  String get shopsTitle;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search;

  /// No description provided for @filters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @chipAll.
  ///
  /// In ru, this message translates to:
  /// **'Все ({count})'**
  String chipAll(int count);

  /// No description provided for @chipScheduled.
  ///
  /// In ru, this message translates to:
  /// **'Запланирован ({count})'**
  String chipScheduled(int count);

  /// No description provided for @chipOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Просрочен ({count})'**
  String chipOverdue(int count);

  /// No description provided for @chipVisited.
  ///
  /// In ru, this message translates to:
  /// **'Пройден ({count})'**
  String chipVisited(int count);

  /// No description provided for @chipNotVisited.
  ///
  /// In ru, this message translates to:
  /// **'Назначен ({count})'**
  String chipNotVisited(int count);

  /// No description provided for @lastVisit.
  ///
  /// In ru, this message translates to:
  /// **'Последний визит:'**
  String get lastVisit;

  /// No description provided for @never.
  ///
  /// In ru, this message translates to:
  /// **'—'**
  String get never;

  /// No description provided for @shopsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Магазинов нет'**
  String get shopsEmpty;

  /// No description provided for @filterRegion.
  ///
  /// In ru, this message translates to:
  /// **'Регион'**
  String get filterRegion;

  /// No description provided for @filterStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get filterStatus;

  /// No description provided for @fromYou.
  ///
  /// In ru, this message translates to:
  /// **'{distance} от вас'**
  String fromYou(String distance);

  /// No description provided for @contactPerson.
  ///
  /// In ru, this message translates to:
  /// **'Контакт'**
  String get contactPerson;

  /// No description provided for @lastVisitDays.
  ///
  /// In ru, this message translates to:
  /// **'{date} ({days} дн. назад)'**
  String lastVisitDays(String date, int days);

  /// No description provided for @lastVisitToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня, {time}'**
  String lastVisitToday(String time);

  /// No description provided for @nextVisit.
  ///
  /// In ru, this message translates to:
  /// **'Следующий визит:'**
  String get nextVisit;

  /// No description provided for @nextVisitOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Срочно (просрочен на {days} дн.)'**
  String nextVisitOverdue(int days);

  /// No description provided for @nextVisitToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get nextVisitToday;

  /// No description provided for @mapButton.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get mapButton;

  /// No description provided for @auditButton.
  ///
  /// In ru, this message translates to:
  /// **'Аудит'**
  String get auditButton;

  /// No description provided for @auditHistory.
  ///
  /// In ru, this message translates to:
  /// **'История аудитов'**
  String get auditHistory;

  /// No description provided for @auditHistoryCount.
  ///
  /// In ru, this message translates to:
  /// **'Всего зафиксировано {count} записей'**
  String auditHistoryCount(int count);

  /// No description provided for @violationRecorded.
  ///
  /// In ru, this message translates to:
  /// **'Зафиксировано нарушение'**
  String get violationRecorded;

  /// No description provided for @photoMaterials.
  ///
  /// In ru, this message translates to:
  /// **'Фотоматериалы ({count} фото)'**
  String photoMaterials(int count);

  /// No description provided for @seeAll.
  ///
  /// In ru, this message translates to:
  /// **'Смотреть все'**
  String get seeAll;

  /// No description provided for @morePhotos.
  ///
  /// In ru, this message translates to:
  /// **'+{count} фото'**
  String morePhotos(int count);

  /// No description provided for @accuracyInside.
  ///
  /// In ru, this message translates to:
  /// **'Точность {meters} метров (в радиусе магазина)'**
  String accuracyInside(int meters);

  /// No description provided for @accuracyOutside.
  ///
  /// In ru, this message translates to:
  /// **'Точность {meters} метров (вне радиуса магазина)'**
  String accuracyOutside(int meters);

  /// No description provided for @visitMissed.
  ///
  /// In ru, this message translates to:
  /// **'Пропущен'**
  String get visitMissed;

  /// No description provided for @pendingSync.
  ///
  /// In ru, this message translates to:
  /// **'Ожидает синхронизации'**
  String get pendingSync;

  /// No description provided for @noAudits.
  ///
  /// In ru, this message translates to:
  /// **'Аудитов пока нет'**
  String get noAudits;

  /// No description provided for @sortNewest.
  ///
  /// In ru, this message translates to:
  /// **'Сначала новые'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In ru, this message translates to:
  /// **'Сначала старые'**
  String get sortOldest;

  /// No description provided for @shopNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Магазин не найден'**
  String get shopNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
