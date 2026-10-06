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
