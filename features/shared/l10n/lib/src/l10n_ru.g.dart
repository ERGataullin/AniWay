import 'package:intl/intl.dart' as intl;

import 'l10n.g.dart';

/// The translations for Russian (`ru`).
class L10nRu extends L10n {
  L10nRu([String locale = 'ru']) : super(locale);

  @override
  String durationSeconds(int seconds) {
    return '$seconds секунд';
  }

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get emailValidationError => 'Неверный адрес электронной почты';

  @override
  String get homePageTitle => 'Главная';

  @override
  String movieEpisode(String type, num episode) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'tv': '$episode серия',
        'movie': 'Фильм',
        'ova': 'OVA $episode',
        'ona': 'ONA $episode',
        'special': 'Спешл $episode',
        'tvSpecial': 'ТВ спешл $episode',
        'ad': 'Реклама $episode',
        'music': 'Музыка $episode',
        'preview': 'Трейлер $episode',
        'other': '$episode серия',
      },
    );
    return '$_temp0';
  }

  @override
  String movieType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'tv': 'ТВ',
        'movie': 'Фильм',
        'ova': 'OVA',
        'ona': 'ONA',
        'special': 'Спешл',
        'tvSpecial': 'ТВ спешл',
        'ad': 'Реклама',
        'music': 'Музыкальное',
        'preview': 'Трейлер',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get popularTitle => 'Популярное';

  @override
  String get signInSubmitLabel => 'Войти';

  @override
  String get signInTitle => 'Авторизация';

  @override
  String get translationLabel => 'Перевод';

  @override
  String get searchPageTitle => 'Поиск';

  @override
  String translationType(String type) {
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
  String get translationTypeLabel => 'Тип перевода';

  @override
  String get upNextTitle => 'К просмотру';
}
