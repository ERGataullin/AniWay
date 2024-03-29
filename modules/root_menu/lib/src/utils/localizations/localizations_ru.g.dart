import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

/// The translations for Russian (`ru`).
class RootMenuLocalizationsRu extends RootMenuLocalizations {
  RootMenuLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String destinationLabel(String destination) {
    String _temp0 = intl.Intl.selectLogic(
      destination,
      {
        'watchNow': 'Смотреть сейчас',
        'store': 'Маркет',
        'library': 'Библиотека',
        'search': 'Поиск',
        'other': '',
      },
    );
    return '$_temp0';
  }
}
