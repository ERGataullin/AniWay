import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';

extension LocalizationsContext on BuildContext {
  MoviesLocalizations get localizations => MoviesLocalizations.of(this);
}
