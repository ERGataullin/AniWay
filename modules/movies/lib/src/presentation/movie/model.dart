import 'package:core/core.dart';

abstract interface class IMovieModel implements ElementaryModel {}

class MovieModel extends ElementaryModel implements IMovieModel {
  MovieModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);
}
