import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_ru.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'src/l10n.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
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
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru')
  ];

  /// No description provided for @authorLabel.
  ///
  /// In ru, this message translates to:
  /// **'Автор'**
  String get authorLabel;

  /// No description provided for @durationSeconds.
  ///
  /// In ru, this message translates to:
  /// **'{seconds} секунд'**
  String durationSeconds(int seconds);

  /// No description provided for @episodesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Список серий'**
  String get episodesLabel;

  /// No description provided for @emailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта'**
  String get emailLabel;

  /// No description provided for @emailValidationError.
  ///
  /// In ru, this message translates to:
  /// **'Неверный адрес электронной почты'**
  String get emailValidationError;

  /// No description provided for @homePageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get homePageTitle;

  /// No description provided for @languageLabel.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get languageLabel;

  /// No description provided for @languageTitle.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, ja{Японский} en{Английский} ru{Русский} other{Неизвестный язык}}'**
  String languageTitle(String type);

  /// No description provided for @movieEpisode.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, tv{{episode} серия} movie{Фильм} ova{OVA {episode}} ona{ONA {episode}} special{Спешл {episode}} tvSpecial{ТВ спешл {episode}} ad{Реклама {episode}} music{Музыка {episode}} preview{Трейлер {episode}} other{{episode} серия}}'**
  String movieEpisode(String type, num episode);

  /// No description provided for @movieType.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, tv{ТВ} movie{Фильм} ova{OVA} ona{ONA} special{Спешл} tvSpecial{ТВ спешл} ad{Реклама} music{Музыкальное} preview{Трейлер} other{}}'**
  String movieType(String type);

  /// No description provided for @ongoingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Cейчас выходят'**
  String get ongoingsTitle;

  /// No description provided for @passwordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get passwordLabel;

  /// No description provided for @playLabel.
  ///
  /// In ru, this message translates to:
  /// **'Смотреть'**
  String get playLabel;

  /// No description provided for @popularsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Популярное'**
  String get popularsTitle;

  /// No description provided for @signInSubmitLabel.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Anime365'**
  String get signInSubmitLabel;

  /// No description provided for @searchPageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get searchPageTitle;

  /// No description provided for @range.
  ///
  /// In ru, this message translates to:
  /// **'{start}-{end}'**
  String range(num start, num end);

  /// No description provided for @upNextTitle.
  ///
  /// In ru, this message translates to:
  /// **'К просмотру'**
  String get upNextTitle;

  /// No description provided for @videoPlaybackSpeedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Скорость воспроизведения'**
  String get videoPlaybackSpeedLabel;

  /// No description provided for @videoPlaybackSpeed.
  ///
  /// In ru, this message translates to:
  /// **'{speed, plural, =1{Обычная} other{{speed}}}'**
  String videoPlaybackSpeed(num speed);

  /// No description provided for @videoQualityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Качество'**
  String get videoQualityLabel;

  /// No description provided for @videoQuality.
  ///
  /// In ru, this message translates to:
  /// **'{quality}p'**
  String videoQuality(num quality);

  /// No description provided for @videoQualityType.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, tv{ТВ} dvd{DVD} bd{BD} other{}}'**
  String videoQualityType(String type);

  /// No description provided for @watchStatusAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в список'**
  String get watchStatusAdd;

  /// No description provided for @watchStatus.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, planned{Запланировано} watching{Смотрю} completed{Просмотрено} onHold{Отложено} dropped{Заброшено} none{В библиотеке отсутствует} other{Неизвестный статус}}'**
  String watchStatus(String type);

  /// No description provided for @xOfY.
  ///
  /// In ru, this message translates to:
  /// **'{x} из {y}'**
  String xOfY(num x, num y);
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru': return L10nRu();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
