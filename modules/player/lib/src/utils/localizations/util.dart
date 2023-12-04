import 'package:flutter/widgets.dart';
import 'package:player/player.dart';

extension LocalizationsContext on BuildContext {
  PlayerLocalizations get localizations => PlayerLocalizations.of(this);
}
