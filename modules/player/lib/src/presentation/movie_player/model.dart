import 'dart:core';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;

abstract interface class IMoviePlayerModel implements ElementaryModel {}

class MoviePlayerModel extends ElementaryModel implements IMoviePlayerModel {
  MoviePlayerModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);
}
