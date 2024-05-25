import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

/// The translations for Russian (`ru`).
class PlayerLocalizationsRu extends PlayerLocalizations {
  PlayerLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String moviePlayerEpisode(String type, num episode) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'tv': '$episode серия',
        'movie': 'Фильм',
        'ova': 'OVA $episode',
        'ona': 'ONA $episode',
        'special': 'Спешл $episode',
        'tvSpecial': 'ТВ спешл $episode',
        'music': 'Музыка $episode',
        'pv': 'Промо $episode',
        'other': '$episode серия',
      },
    );
    return '$_temp0';
  }

  @override
  String get moviePlayerPreferencesTranslationTypeLabel => 'Тип перевода';

  @override
  String moviePlayerPreferencesTranslationType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'raw': 'Оригинал',
        'sub': 'Субтитры',
        'voice': 'Озвучка',
        'other': 'Неизвестный тип',
      },
    );
    return '$_temp0';
  }

  @override
  String get moviePlayerPreferencesTranslationLabel => 'Перевод';

  @override
  String seekAreaSeekValue(int seconds) {
    return '$seconds секунд';
  }
}
