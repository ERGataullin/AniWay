// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.g.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class L10nRu extends L10n {
  L10nRu([String locale = 'ru']) : super(locale);

  @override
  String get all => 'Все';

  @override
  String get authorLabel => 'Автор';

  @override
  String get commentLabel => 'Комментарий';

  @override
  String get delete => 'Удалить';

  @override
  String durationSeconds(int seconds) {
    return '$seconds секунд';
  }

  @override
  String get episodesLabel => 'Список серий';

  @override
  String get episodesWatchedLabel => 'Просмотрено серий';

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
    String _temp0 = intl.Intl.selectLogic(type, {
      'ru': 'Русский',
      'uk': 'Украинский',
      'en': 'Английский',
      'ja': 'Японский',
      'other': 'Неизвестный язык',
    });
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'Мой список';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String movieEpisode(String type, num episode) {
    String _temp0 = intl.Intl.selectLogic(type, {
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
    });
    return '$_temp0';
  }

  @override
  String movieType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
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
    });
    return '$_temp0';
  }

  @override
  String ofY(num y) {
    return 'из $y';
  }

  @override
  String get ongoingsTitle => 'Cейчас выходят';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get playbackSpeedLabel => 'Скорость воспроизведения';

  @override
  String playbackSpeed(num speed) {
    String _temp0 = intl.Intl.pluralLogic(
      speed,
      locale: localeName,
      other: '$speed',
      one: 'Обычная',
    );
    return '$_temp0';
  }

  @override
  String get playLabel => 'Смотреть';

  @override
  String get popularsTitle => 'Популярное';

  @override
  String get qualityLabel => 'Качество';

  @override
  String quality(Object quality) {
    return '${quality}p';
  }

  @override
  String qualityType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'tv': 'ТВ',
      'dvd': 'DVD',
      'bd': 'BD',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String range(num start, num end) {
    return '$start-$end';
  }

  @override
  String releasedCount(int count) {
    return 'Вышло $count';
  }

  @override
  String get save => 'Сохранить';

  @override
  String get searchPageTitle => 'Поиск';

  @override
  String get score => 'Оценка';

  @override
  String get signInSubmitLabel => 'Войти через Anime365';

  @override
  String get statusLabel => 'Статус';

  @override
  String get translationTypeLabel => 'Тип перевода';

  @override
  String translationType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'raw': 'Оригинал',
      'sub': 'Субтитры',
      'voice': 'Озвучка',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get upNextTitle => 'К просмотру';

  @override
  String get watchStatusTitle => 'Добавить в список';

  @override
  String watchStatusEpisodesError(num episodesCountTotal) {
    return 'Не более $episodesCountTotal серий';
  }

  @override
  String watchStatus(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'planned': 'Запланировано',
      'watching': 'Смотрю',
      'completed': 'Просмотрено',
      'onHold': 'Отложено',
      'dropped': 'Брошено',
      'other': 'Неизвестный статус',
    });
    return '$_temp0';
  }

  @override
  String xOfY(num x, num y) {
    return '$x из $y';
  }
}
