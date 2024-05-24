import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

/// The translations for Russian (`ru`).
class MoviesLocalizationsRu extends MoviesLocalizations {
  MoviesLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get homeMostPopularLabel => 'Самое популярное на AniWay';

  @override
  String get homeTitle => 'Главная';

  @override
  String get homeUpNextLabel => 'К просмотру';

  @override
  String moviePreviewType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'tv': 'ТВ',
        'movie': 'Фильм',
        'ova': 'OVA',
        'ona': 'ONA',
        'special': 'Спешл',
        'tvSpecial': 'ТВ спешл',
        'music': 'Музыкальное',
        'pv': 'Промо',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get searchSearchBarHint => 'Поиск';

  @override
  String upNextStatus(String type, num episode) {
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
}
