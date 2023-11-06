import 'package:flutter/widgets.dart';
import 'package:menu/menu.dart';

extension LocalizationsContext on BuildContext {
  MenuLocalizations get localizations => MenuLocalizations.of(this);
}
