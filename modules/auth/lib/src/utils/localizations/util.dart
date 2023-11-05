import 'package:auth/auth.dart';
import 'package:flutter/widgets.dart';

extension LocalizationsContext on BuildContext {
  AuthLocalizations get localizations => AuthLocalizations.of(this);
}
