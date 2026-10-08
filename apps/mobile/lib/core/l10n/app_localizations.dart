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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ru')];

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

  /// No description provided for @mapSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск магазина, владельца, телефона…'**
  String get mapSearch;

  /// No description provided for @mapAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get mapAll;

  /// No description provided for @mapNotVisited.
  ///
  /// In ru, this message translates to:
  /// **'Не посещённые({count})'**
  String mapNotVisited(int count);

  /// No description provided for @mapVisited.
  ///
  /// In ru, this message translates to:
  /// **'Посещённые({count})'**
  String mapVisited(int count);

  /// No description provided for @mapRecent.
  ///
  /// In ru, this message translates to:
  /// **'Недавно'**
  String get mapRecent;

  /// No description provided for @myLocation.
  ///
  /// In ru, this message translates to:
  /// **'Моё местоположение'**
  String get myLocation;

  /// No description provided for @zoomIn.
  ///
  /// In ru, this message translates to:
  /// **'Приблизить карту'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In ru, this message translates to:
  /// **'Отдалить карту'**
  String get zoomOut;

  /// No description provided for @startAudit.
  ///
  /// In ru, this message translates to:
  /// **'Начать Аудит'**
  String get startAudit;

  /// No description provided for @auditOnlyOnSite.
  ///
  /// In ru, this message translates to:
  /// **'Начать аудит можно только на территории магазина'**
  String get auditOnlyOnSite;

  /// No description provided for @locating.
  ///
  /// In ru, this message translates to:
  /// **'Определяем местоположение…'**
  String get locating;

  /// No description provided for @auditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проведение Аудита'**
  String get auditTitle;

  /// No description provided for @offlineSaved.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн-режим сохранён'**
  String get offlineSaved;

  /// No description provided for @geoLocating.
  ///
  /// In ru, this message translates to:
  /// **'Определение местоположения...'**
  String get geoLocating;

  /// No description provided for @geoOutside.
  ///
  /// In ru, this message translates to:
  /// **'Вы вне территории магазина ({meters} м)'**
  String geoOutside(int meters);

  /// No description provided for @geoInaccurate.
  ///
  /// In ru, this message translates to:
  /// **'Слабый сигнал GPS (точность {meters} м)'**
  String geoInaccurate(int meters);

  /// No description provided for @geoUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Местоположение недоступно'**
  String get geoUnavailable;

  /// No description provided for @recheck.
  ///
  /// In ru, this message translates to:
  /// **'Проверить заново'**
  String get recheck;

  /// No description provided for @photoEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фото POSM ещё не сделано'**
  String get photoEmptyTitle;

  /// No description provided for @photoEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Сфотографируйте постеры, воблеры, ценники и шелфтокеры в зоне видимости покупателя'**
  String get photoEmptyHint;

  /// No description provided for @takePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Сделать фото'**
  String get takePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Удалить фото'**
  String get removePhoto;

  /// No description provided for @auditComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий к аудиту'**
  String get auditComment;

  /// No description provided for @auditCommentHint.
  ///
  /// In ru, this message translates to:
  /// **'Напишите замечания или дополнительную информацию о состоянии торговой точки...'**
  String get auditCommentHint;

  /// No description provided for @violationChip.
  ///
  /// In ru, this message translates to:
  /// **'Нарушение'**
  String get violationChip;

  /// No description provided for @finishAudit.
  ///
  /// In ru, this message translates to:
  /// **'Завершить аудит'**
  String get finishAudit;

  /// No description provided for @auditSaved.
  ///
  /// In ru, this message translates to:
  /// **'Аудит сохранён. Он отправится при появлении сети.'**
  String get auditSaved;

  /// No description provided for @photoLimit.
  ///
  /// In ru, this message translates to:
  /// **'Не больше {count} фото'**
  String photoLimit(int count);

  /// No description provided for @addShopTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить Магазин'**
  String get addShopTitle;

  /// No description provided for @shopName.
  ///
  /// In ru, this message translates to:
  /// **'Название магазина'**
  String get shopName;

  /// No description provided for @shopNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Maya shop'**
  String get shopNameHint;

  /// No description provided for @address.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In ru, this message translates to:
  /// **'West Boulevard'**
  String get addressHint;

  /// No description provided for @owner.
  ///
  /// In ru, this message translates to:
  /// **'Владелец'**
  String get owner;

  /// No description provided for @ownerHint.
  ///
  /// In ru, this message translates to:
  /// **'John Doe'**
  String get ownerHint;

  /// No description provided for @phoneNumber.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In ru, this message translates to:
  /// **'+993 62 112233'**
  String get phoneHint;

  /// No description provided for @clear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clear;

  /// No description provided for @currentLocation.
  ///
  /// In ru, this message translates to:
  /// **'Текущее местоположение'**
  String get currentLocation;

  /// No description provided for @coordsLine.
  ///
  /// In ru, this message translates to:
  /// **'Lat: {lat}° N, Long: {lng}° E'**
  String coordsLine(String lat, String lng);

  /// No description provided for @accuracyLine.
  ///
  /// In ru, this message translates to:
  /// **'Точность GPS: {meters} м'**
  String accuracyLine(int meters);

  /// No description provided for @storefrontPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Фото витрины'**
  String get storefrontPhoto;

  /// No description provided for @photoCaptured.
  ///
  /// In ru, this message translates to:
  /// **'Фото сделано · {size}'**
  String photoCaptured(String size);

  /// No description provided for @photoNotTaken.
  ///
  /// In ru, this message translates to:
  /// **'Фото ещё не сделано'**
  String get photoNotTaken;

  /// No description provided for @storefrontHint.
  ///
  /// In ru, this message translates to:
  /// **'Сфотографируйте фасад и вывеску магазина'**
  String get storefrontHint;

  /// No description provided for @retake.
  ///
  /// In ru, this message translates to:
  /// **'Переснять'**
  String get retake;

  /// No description provided for @shopSaved.
  ///
  /// In ru, this message translates to:
  /// **'Магазин сохранён и отправлен на проверку'**
  String get shopSaved;

  /// No description provided for @galleryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get galleryTitle;

  /// No description provided for @galleryLibrary.
  ///
  /// In ru, this message translates to:
  /// **'Медиатека инспекций'**
  String get galleryLibrary;

  /// No description provided for @photoCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} фото'**
  String photoCount(int count);

  /// No description provided for @cloudUpToDate.
  ///
  /// In ru, this message translates to:
  /// **'Облако актуально'**
  String get cloudUpToDate;

  /// No description provided for @quickSearch.
  ///
  /// In ru, this message translates to:
  /// **'Быстрый поиск'**
  String get quickSearch;

  /// No description provided for @filterParams.
  ///
  /// In ru, this message translates to:
  /// **'Параметры фильтрации'**
  String get filterParams;

  /// No description provided for @filterDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get filterDate;

  /// No description provided for @dateToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get dateToday;

  /// No description provided for @date7.
  ///
  /// In ru, this message translates to:
  /// **'7 дней'**
  String get date7;

  /// No description provided for @date30.
  ///
  /// In ru, this message translates to:
  /// **'30 дней'**
  String get date30;

  /// No description provided for @filterShop.
  ///
  /// In ru, this message translates to:
  /// **'Магазин'**
  String get filterShop;

  /// No description provided for @todayDate.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня, {date}'**
  String todayDate(String date);

  /// No description provided for @relatedPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Связанные фото аудита ({count})'**
  String relatedPhotos(int count);

  /// No description provided for @noPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фото пока нет'**
  String get noPhotos;

  /// No description provided for @searchShop.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по магазину'**
  String get searchShop;

  /// No description provided for @totalShops.
  ///
  /// In ru, this message translates to:
  /// **'Всего точек: {count}'**
  String totalShops(int count);

  /// No description provided for @sortAZ.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка: A-Z'**
  String get sortAZ;

  /// No description provided for @sortZA.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка: Z-A'**
  String get sortZA;

  /// No description provided for @typeHYPERMARKET.
  ///
  /// In ru, this message translates to:
  /// **'Гипермаркет'**
  String get typeHYPERMARKET;

  /// No description provided for @typeSUPERMARKET.
  ///
  /// In ru, this message translates to:
  /// **'Супермаркет'**
  String get typeSUPERMARKET;

  /// No description provided for @typeMARKET.
  ///
  /// In ru, this message translates to:
  /// **'Маркет'**
  String get typeMARKET;

  /// No description provided for @typeMINIMARKET.
  ///
  /// In ru, this message translates to:
  /// **'Минимаркет'**
  String get typeMINIMARKET;

  /// No description provided for @typeOTHER.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get typeOTHER;

  /// No description provided for @statusACTIVE.
  ///
  /// In ru, this message translates to:
  /// **'Активен'**
  String get statusACTIVE;

  /// No description provided for @statusPENDING_REVIEW.
  ///
  /// In ru, this message translates to:
  /// **'На проверке'**
  String get statusPENDING_REVIEW;

  /// No description provided for @statusINACTIVE.
  ///
  /// In ru, this message translates to:
  /// **'Неактивен'**
  String get statusINACTIVE;

  /// No description provided for @agentLabel.
  ///
  /// In ru, this message translates to:
  /// **'Агент: '**
  String get agentLabel;

  /// No description provided for @unassigned.
  ///
  /// In ru, this message translates to:
  /// **'Не назначен'**
  String get unassigned;

  /// No description provided for @auditsTotal.
  ///
  /// In ru, this message translates to:
  /// **'{count} аудитов всего'**
  String auditsTotal(int count);

  /// No description provided for @lastVisitShort.
  ///
  /// In ru, this message translates to:
  /// **'Посл. визит: {date}'**
  String lastVisitShort(String date);

  /// No description provided for @details.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get details;

  /// No description provided for @callShop.
  ///
  /// In ru, this message translates to:
  /// **'Позвонить в магазин'**
  String get callShop;

  /// No description provided for @navigate.
  ///
  /// In ru, this message translates to:
  /// **'В навигаторе'**
  String get navigate;

  /// No description provided for @loadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить. Потяните, чтобы обновить.'**
  String get loadError;

  /// No description provided for @shopDetailsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Детали магазина'**
  String get shopDetailsTitle;

  /// No description provided for @actions.
  ///
  /// In ru, this message translates to:
  /// **'Действия'**
  String get actions;

  /// No description provided for @share.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get share;

  /// No description provided for @editShop.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать точку'**
  String get editShop;

  /// No description provided for @totalAudits.
  ///
  /// In ru, this message translates to:
  /// **'Всего аудитов'**
  String get totalAudits;

  /// No description provided for @auditsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} аудитов'**
  String auditsCount(int count);

  /// No description provided for @lastVisitTitle.
  ///
  /// In ru, this message translates to:
  /// **'Крайний визит'**
  String get lastVisitTitle;

  /// No description provided for @addressRegion.
  ///
  /// In ru, this message translates to:
  /// **'Адрес и регион'**
  String get addressRegion;

  /// No description provided for @responsibleAgent.
  ///
  /// In ru, this message translates to:
  /// **'Ответственный агент'**
  String get responsibleAgent;

  /// No description provided for @contact.
  ///
  /// In ru, this message translates to:
  /// **'Связаться'**
  String get contact;

  /// No description provided for @onShift.
  ///
  /// In ru, this message translates to:
  /// **'На смене'**
  String get onShift;

  /// No description provided for @offShift.
  ///
  /// In ru, this message translates to:
  /// **'Не на смене'**
  String get offShift;

  /// No description provided for @photoReports.
  ///
  /// In ru, this message translates to:
  /// **'Фотоотчёты аудитов'**
  String get photoReports;

  /// No description provided for @openGallery.
  ///
  /// In ru, this message translates to:
  /// **'Открыть галерею'**
  String get openGallery;

  /// No description provided for @geolocation.
  ///
  /// In ru, this message translates to:
  /// **'Геолокация объекта'**
  String get geolocation;

  /// No description provided for @agent.
  ///
  /// In ru, this message translates to:
  /// **'Агент'**
  String get agent;

  /// No description provided for @editShopTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать магазин'**
  String get editShopTitle;

  /// No description provided for @selectAgent.
  ///
  /// In ru, this message translates to:
  /// **'Выберите агента'**
  String get selectAgent;

  /// No description provided for @saveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить. Проверьте поля и попробуйте ещё раз.'**
  String get saveFailed;

  /// No description provided for @agentsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Агенты'**
  String get agentsTitle;

  /// No description provided for @kpiStaff.
  ///
  /// In ru, this message translates to:
  /// **'Всего в штате'**
  String get kpiStaff;

  /// No description provided for @kpiOnRoute.
  ///
  /// In ru, this message translates to:
  /// **'На маршруте'**
  String get kpiOnRoute;

  /// No description provided for @kpiAudits.
  ///
  /// In ru, this message translates to:
  /// **'Аудиты ТТ'**
  String get kpiAudits;

  /// No description provided for @kpiPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фотоотчёты'**
  String get kpiPhotos;

  /// No description provided for @people.
  ///
  /// In ru, this message translates to:
  /// **'чел.'**
  String get people;

  /// No description provided for @online.
  ///
  /// In ru, this message translates to:
  /// **'онлайн'**
  String get online;

  /// No description provided for @sheets.
  ///
  /// In ru, this message translates to:
  /// **'листа'**
  String get sheets;

  /// No description provided for @frames.
  ///
  /// In ru, this message translates to:
  /// **'кадров'**
  String get frames;

  /// No description provided for @onShiftOf.
  ///
  /// In ru, this message translates to:
  /// **'{pct}% в смене (из {total})'**
  String onShiftOf(String pct, int total);

  /// No description provided for @ofPool.
  ///
  /// In ru, this message translates to:
  /// **'{pct}% пула на линии'**
  String ofPool(String pct);

  /// No description provided for @vsPlan.
  ///
  /// In ru, this message translates to:
  /// **'{pct}% к плану дня'**
  String vsPlan(String pct);

  /// No description provided for @validPhotos.
  ///
  /// In ru, this message translates to:
  /// **'{pct}% валидных'**
  String validPhotos(String pct);

  /// No description provided for @locations.
  ///
  /// In ru, this message translates to:
  /// **'Локации: {count}'**
  String locations(int count);

  /// No description provided for @photosShort.
  ///
  /// In ru, this message translates to:
  /// **'Фото:{count}'**
  String photosShort(int count);

  /// No description provided for @lastActivity.
  ///
  /// In ru, this message translates to:
  /// **'Активность: {when}'**
  String lastActivity(String when);

  /// No description provided for @noActivity.
  ///
  /// In ru, this message translates to:
  /// **'Нет активности'**
  String get noActivity;

  /// No description provided for @callAgent.
  ///
  /// In ru, this message translates to:
  /// **'Позвонить агенту'**
  String get callAgent;

  /// No description provided for @agentsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Агентов нет'**
  String get agentsEmpty;

  /// No description provided for @agentDetailsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Детали агента'**
  String get agentDetailsTitle;

  /// No description provided for @exportPdfXls.
  ///
  /// In ru, this message translates to:
  /// **'PDF/XLS'**
  String get exportPdfXls;

  /// No description provided for @exportPdf.
  ///
  /// In ru, this message translates to:
  /// **'Отчёт PDF'**
  String get exportPdf;

  /// No description provided for @exportXls.
  ///
  /// In ru, this message translates to:
  /// **'Отчёт Excel'**
  String get exportXls;

  /// No description provided for @exportFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сформировать отчёт'**
  String get exportFailed;

  /// No description provided for @sectorLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сектор: '**
  String get sectorLabel;

  /// No description provided for @onlineGps.
  ///
  /// In ru, this message translates to:
  /// **'В сети (GPS активен, ±{meters}м)'**
  String onlineGps(int meters);

  /// No description provided for @offlineSince.
  ///
  /// In ru, this message translates to:
  /// **'Не в сети'**
  String get offlineSince;

  /// No description provided for @updatedAgo.
  ///
  /// In ru, this message translates to:
  /// **'Обновлено {when}'**
  String updatedAgo(String when);

  /// No description provided for @kpiAllAudits.
  ///
  /// In ru, this message translates to:
  /// **'Аудиты за всё время'**
  String get kpiAllAudits;

  /// No description provided for @checklists.
  ///
  /// In ru, this message translates to:
  /// **'чек-листов'**
  String get checklists;

  /// No description provided for @kpiShopPlan.
  ///
  /// In ru, this message translates to:
  /// **'План магазинов'**
  String get kpiShopPlan;

  /// No description provided for @outlets.
  ///
  /// In ru, this message translates to:
  /// **'точек'**
  String get outlets;

  /// No description provided for @kpiVisited.
  ///
  /// In ru, this message translates to:
  /// **'Посещено'**
  String get kpiVisited;

  /// No description provided for @ofOutlets.
  ///
  /// In ru, this message translates to:
  /// **'из {total} ({pct}%)'**
  String ofOutlets(int total, String pct);

  /// No description provided for @kpiPhotosAll.
  ///
  /// In ru, this message translates to:
  /// **'Фотографий'**
  String get kpiPhotosAll;

  /// No description provided for @routeTracking.
  ///
  /// In ru, this message translates to:
  /// **'Маршрут и трекинг'**
  String get routeTracking;

  /// No description provided for @hereNow.
  ///
  /// In ru, this message translates to:
  /// **'{name} (сейчас здесь)'**
  String hereNow(String name);

  /// No description provided for @checkpointHistory.
  ///
  /// In ru, this message translates to:
  /// **'История чекпоинтов'**
  String get checkpointHistory;

  /// No description provided for @pointsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} точек'**
  String pointsCount(int count);

  /// No description provided for @stopDONE.
  ///
  /// In ru, this message translates to:
  /// **'Выполнен'**
  String get stopDONE;

  /// No description provided for @stopMISSED.
  ///
  /// In ru, this message translates to:
  /// **'Пропущен'**
  String get stopMISSED;

  /// No description provided for @stopIN_PROGRESS.
  ///
  /// In ru, this message translates to:
  /// **'В процессе'**
  String get stopIN_PROGRESS;

  /// No description provided for @stopPLANNED.
  ///
  /// In ru, this message translates to:
  /// **'План'**
  String get stopPLANNED;

  /// No description provided for @syncingData.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация данных...'**
  String get syncingData;

  /// No description provided for @plannedVisit.
  ///
  /// In ru, this message translates to:
  /// **'Плановый визит'**
  String get plannedVisit;

  /// No description provided for @visitHistory.
  ///
  /// In ru, this message translates to:
  /// **'История визитов'**
  String get visitHistory;

  /// No description provided for @updatedAt.
  ///
  /// In ru, this message translates to:
  /// **'Обновлено в {time}'**
  String updatedAt(String time);

  /// No description provided for @durationMin.
  ///
  /// In ru, this message translates to:
  /// **'({minutes} мин)'**
  String durationMin(int minutes);

  /// No description provided for @statusDone.
  ///
  /// In ru, this message translates to:
  /// **'Завершён'**
  String get statusDone;

  /// No description provided for @morePhotosOpen.
  ///
  /// In ru, this message translates to:
  /// **'+{count} фото'**
  String morePhotosOpen(int count);

  /// No description provided for @addSalesmanTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить агента'**
  String get addSalesmanTitle;

  /// No description provided for @fullName.
  ///
  /// In ru, this message translates to:
  /// **'ФИО'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, Довлет Оразов'**
  String get fullNameHint;

  /// No description provided for @employeeCode.
  ///
  /// In ru, this message translates to:
  /// **'Табельный номер / Код'**
  String get employeeCode;

  /// No description provided for @generateCode.
  ///
  /// In ru, this message translates to:
  /// **'Сгенерировать'**
  String get generateCode;

  /// No description provided for @whatsapp.
  ///
  /// In ru, this message translates to:
  /// **'Доп. телефон / WhatsApp'**
  String get whatsapp;

  /// No description provided for @routeNotes.
  ///
  /// In ru, this message translates to:
  /// **'Заметки / график маршрута'**
  String get routeNotes;

  /// No description provided for @routeNotesHint.
  ///
  /// In ru, this message translates to:
  /// **'Краткое описание сектора или дней маршрута'**
  String get routeNotesHint;

  /// No description provided for @visitPlan.
  ///
  /// In ru, this message translates to:
  /// **'План визитов в день (магазинов)'**
  String get visitPlan;

  /// No description provided for @auditPlan.
  ///
  /// In ru, this message translates to:
  /// **'Чек-листы / аудиты в день'**
  String get auditPlan;

  /// No description provided for @regionField.
  ///
  /// In ru, this message translates to:
  /// **'Регион / территория продаж'**
  String get regionField;

  /// No description provided for @selectRegion.
  ///
  /// In ru, this message translates to:
  /// **'Выберите регион'**
  String get selectRegion;

  /// No description provided for @workStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус активности сотрудника'**
  String get workStatus;

  /// No description provided for @onLeave.
  ///
  /// In ru, this message translates to:
  /// **'В отпуске'**
  String get onLeave;

  /// No description provided for @agentCreated.
  ///
  /// In ru, this message translates to:
  /// **'Агент добавлен'**
  String get agentCreated;

  /// No description provided for @tempPassword.
  ///
  /// In ru, this message translates to:
  /// **'Временный пароль (показывается один раз, передайте его агенту):'**
  String get tempPassword;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @planError.
  ///
  /// In ru, this message translates to:
  /// **'План аудитов не может превышать план визитов'**
  String get planError;

  /// No description provided for @productsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Продукции'**
  String get productsTitle;

  /// No description provided for @productsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Продукции нет'**
  String get productsEmpty;

  /// No description provided for @addProductTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить продукт'**
  String get addProductTitle;

  /// No description provided for @sku.
  ///
  /// In ru, this message translates to:
  /// **'Артикул (SKU)'**
  String get sku;

  /// No description provided for @productName.
  ///
  /// In ru, this message translates to:
  /// **'Название продукта'**
  String get productName;

  /// No description provided for @category.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In ru, this message translates to:
  /// **'Выберите категорию'**
  String get selectCategory;

  /// No description provided for @brand.
  ///
  /// In ru, this message translates to:
  /// **'Бренд'**
  String get brand;

  /// No description provided for @retailPrice.
  ///
  /// In ru, this message translates to:
  /// **'Розничная цена'**
  String get retailPrice;

  /// No description provided for @description.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get description;

  /// No description provided for @productImage.
  ///
  /// In ru, this message translates to:
  /// **'Изображение продукта'**
  String get productImage;

  /// No description provided for @productImageHint.
  ///
  /// In ru, this message translates to:
  /// **'PNG или JPG, до 5 МБ'**
  String get productImageHint;

  /// No description provided for @statusDRAFT.
  ///
  /// In ru, this message translates to:
  /// **'Черновик'**
  String get statusDRAFT;

  /// No description provided for @productStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get productStatus;

  /// No description provided for @stockTracked.
  ///
  /// In ru, this message translates to:
  /// **'Учитывать остатки'**
  String get stockTracked;

  /// No description provided for @stockQty.
  ///
  /// In ru, this message translates to:
  /// **'Остаток на складе'**
  String get stockQty;

  /// No description provided for @minStockAlert.
  ///
  /// In ru, this message translates to:
  /// **'Минимальный остаток'**
  String get minStockAlert;

  /// No description provided for @coverage.
  ///
  /// In ru, this message translates to:
  /// **'Покрытие: {pct}%'**
  String coverage(String pct);

  /// No description provided for @locationsShort.
  ///
  /// In ru, this message translates to:
  /// **'Точек: {count}'**
  String locationsShort(int count);

  /// No description provided for @price.
  ///
  /// In ru, this message translates to:
  /// **'{price} TMT'**
  String price(String price);

  /// No description provided for @skuConflict.
  ///
  /// In ru, this message translates to:
  /// **'Такой артикул уже есть'**
  String get skuConflict;

  /// No description provided for @pickOnMap.
  ///
  /// In ru, this message translates to:
  /// **'Указать на карте'**
  String get pickOnMap;

  /// No description provided for @mapPickTitle.
  ///
  /// In ru, this message translates to:
  /// **'Расположение магазина'**
  String get mapPickTitle;

  /// No description provided for @mapPickHint.
  ///
  /// In ru, this message translates to:
  /// **'Перемещайте карту, чтобы поставить метку на вход в магазин'**
  String get mapPickHint;

  /// No description provided for @mapPickDone.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать эту точку'**
  String get mapPickDone;

  /// No description provided for @pickedOnMap.
  ///
  /// In ru, this message translates to:
  /// **'Точка выбрана на карте'**
  String get pickedOnMap;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

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
