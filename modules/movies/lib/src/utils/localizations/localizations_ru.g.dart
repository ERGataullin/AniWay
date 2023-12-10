import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

/// The translations for Russian (`ru`).
class MoviesLocalizationsRu extends MoviesLocalizations {
  MoviesLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String componentsMoviePreviewType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'tv': 'ТВ',
        'movie': 'Фильм',
        'ova': 'OVA',
        'ona': 'ONA',
        'special': 'Спешл',
        'music': 'Музыкальное',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String componentsUpNextStatus(String watchStatus, String type, num episode) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'tv': '$episode серия',
        'movie': 'Фильм',
        'ova': 'OVA $episode серия',
        'ona': 'ONA $episode серия',
        'special': 'Спешл $episode серия',
        'other': '$episode серия',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      type,
      {
        'tv': '$episode серия',
        'ova': 'OVA $episode серия',
        'ona': 'ONA $episode серия',
        'special': 'Спешл $episode серия',
        'other': '$episode серия',
      },
    );
    String _temp2 = intl.Intl.selectLogic(
      watchStatus,
      {
        'watching': '$_temp0',
        'rewatching': '$_temp1',
        'planned': 'Запланировано',
        'onHold': 'Отложено на $episode серии',
        'other': '$episode серия',
      },
    );
    return '$_temp2';
  }

  @override
  String get watchNowMostPopularLabel => 'Самое популярное на AniWay';

  @override
  String get watchNowTitle => 'Смотреть сейчас';

  @override
  String get watchNowUpNextLabel => 'К просмотру';

  @override
  String get searchSearchBarHint => 'Поиск';
}
