import 'package:intl/intl.dart' as intl;

import 'l10n.g.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class L10nRu extends L10n {
  L10nRu([String locale = 'ru']) : super(locale);

  @override
  String get authorLabel => 'Автор';

  @override
  String durationSeconds(int seconds) {
    return '$seconds секунд';
  }

  @override
  String get episodesLabel => 'Список серий';

  @override
  String episodesLabelDetails(Object episodes, Object numberOfEpisodes) {
    return 'Cписок серий $episodes / $numberOfEpisodes';
  }

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get emailValidationError => 'Неверный адрес электронной почты';

  @override
  String get homePageTitle => 'Главная';

  @override
  String get languageLabel => 'Язык';

  @override
  String languageTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'ja': 'Японский',
        'en': 'Английский',
        'ru': 'Русский',
        'other': 'Неизвестный язык',
      },
    );
    return '$_temp0';
  }

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
  String get ongoingsTitle => 'Cейчас выходят';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get playLabel => 'Смотреть';

  @override
  String get popularsTitle => 'Популярное';

  @override
  String get signInSubmitLabel => 'Войти через Anime365';

  @override
  String get searchPageTitle => 'Поиск';

  @override
  String range(num start, num end) {
    return '$start-$end';
  }

  @override
  String get upNextTitle => 'К просмотру';

  @override
  String get videoPlaybackSpeedLabel => 'Скорость воспроизведения';

  @override
  String videoPlaybackSpeed(num speed) {
    String _temp0 = intl.Intl.pluralLogic(
      speed,
      locale: localeName,
      other: '$speed',
      one: 'Обычная',
    );
    return '$_temp0';
  }

  @override
  String get videoQualityLabel => 'Качество';

  @override
  String videoQuality(num quality) {
    return '${quality}p';
  }

  @override
  String videoQualityType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'tv': 'ТВ',
        'dvd': 'DVD',
        'bd': 'BD',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get watchStatusAdd => 'Добавить в список';

  @override
  String watchStatus(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'planned': 'Запланировано',
        'watching': 'Смотрю',
        'completed': 'Просмотрено',
        'onHold': 'Отложено',
        'dropped': 'Заброшено',
        'none': 'В библиотеке отсутствует',
        'other': 'Неизвестный статус',
      },
    );
    return '$_temp0';
  }
}
