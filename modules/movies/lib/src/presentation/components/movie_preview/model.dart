import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/models/movie_type.dart';

abstract interface class IMoviePreviewModel implements ElementaryModel {
  ValueListenable<Uri> get posterUri;

  ValueListenable<String> get title;

  ValueListenable<MovieTypeData> get type;

  ValueListenable<num> get score;

  set movie(MoviePreviewData value);
}

class MoviePreviewModel extends ElementaryModel implements IMoviePreviewModel {
  MoviePreviewModel(
    ErrorHandler errorHandler, {
    required Uri posterBaseUri,
  })  : _posterBaseUri = posterBaseUri,
        super(errorHandler: errorHandler);

  @override
  final ValueNotifier<Uri> posterUri = ValueNotifier(Uri());

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<MovieTypeData> type = ValueNotifier(
    MovieTypeData.unknown,
  );

  @override
  final ValueNotifier<num> score = ValueNotifier(0);

  @override
  set movie(MoviePreviewData value) {
    _movie = value;
    posterUri.value = _posterBaseUri.resolveUri(_movie.posterUri);
    title.value = _movie.title;
    type.value = _movie.type;
    score.value = _movie.score;
  }

  final Uri _posterBaseUri;

  late MoviePreviewData _movie;

  @override
  void dispose() {
    super.dispose();
    posterUri.dispose();
    title.dispose();
    type.dispose();
    score.dispose();
  }
}
