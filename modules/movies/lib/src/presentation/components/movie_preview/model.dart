import 'package:core/core.dart';

abstract interface class IMoviePreviewModel implements ElementaryModel {}

class MoviePreviewModel extends ElementaryModel implements IMoviePreviewModel {
  MoviePreviewModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);
}
