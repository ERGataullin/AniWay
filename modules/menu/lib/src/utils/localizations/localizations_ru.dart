import 'package:intl/intl.dart' as intl;

import 'localizations.dart';

/// The translations for Russian (`ru`).
class MenuLocalizationsRu extends MenuLocalizations {
  MenuLocalizationsRu([String locale = 'ru']) : super(locale);

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
