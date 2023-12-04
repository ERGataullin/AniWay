import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localizations_ru.g.dart';

/// Callers can lookup localized strings with an instance of MoviesLocalizations
/// returned by `MoviesLocalizations.of(context)`.
///
/// Applications need to include `MoviesLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localizations/localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MoviesLocalizations.localizationsDelegates,
///   supportedLocales: MoviesLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the MoviesLocalizations.supportedLocales
/// property.
abstract class MoviesLocalizations {
  MoviesLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MoviesLocalizations of(BuildContext context) {
    return Localizations.of<MoviesLocalizations>(context, MoviesLocalizations)!;
  }

  static const LocalizationsDelegate<MoviesLocalizations> delegate = _MoviesLocalizationsDelegate();

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

  /// No description provided for @componentsMoviePreviewType.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, tv{ТВ} movie{Фильм} ova{OVA} ona{ONA} special{Спешл} music{Музыкальное} other{}}'**
  String componentsMoviePreviewType(String type);

  /// No description provided for @componentsUpNextStatus.
  ///
  /// In ru, this message translates to:
  /// **'{watchStatus, select, watching{{type, select, tv{{episode} серия} movie{Фильм} ova{OVA {episode} серия} ona{ONA {episode} серия} special{Спешл {episode} серия} other{{episode} серия}}} rewatching{{type, select, tv{{episode} серия} ova{OVA {episode} серия} ona{ONA {episode} серия} special{Спешл {episode} серия} other{{episode} серия}}} planned{Запланировано} onHold{Отложено на {episode} серии} other{{episode} серия}}'**
  String componentsUpNextStatus(String watchStatus, String type, num episode);

  /// No description provided for @watchNowMostPopularLabel.
  ///
  /// In ru, this message translates to:
  /// **'Самое популярное на AniWay'**
  String get watchNowMostPopularLabel;

  /// No description provided for @watchNowTitle.
  ///
  /// In ru, this message translates to:
  /// **'Смотреть сейчас'**
  String get watchNowTitle;

  /// No description provided for @watchNowUpNextLabel.
  ///
  /// In ru, this message translates to:
  /// **'К просмотру'**
  String get watchNowUpNextLabel;

  /// No description provided for @hintText.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get hintText;
}

class _MoviesLocalizationsDelegate extends LocalizationsDelegate<MoviesLocalizations> {
  const _MoviesLocalizationsDelegate();

  @override
  Future<MoviesLocalizations> load(Locale locale) {
    return SynchronousFuture<MoviesLocalizations>(lookupMoviesLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_MoviesLocalizationsDelegate old) => false;
}

MoviesLocalizations lookupMoviesLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru': return MoviesLocalizationsRu();
  }

  throw FlutterError(
    'MoviesLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
