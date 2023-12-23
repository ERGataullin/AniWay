import 'package:flutter/widgets.dart';
import 'package:root_menu/root_menu.dart';

extension LocalizationsContext on BuildContext {
  RootMenuLocalizations get localizations => RootMenuLocalizations.of(this);
}
