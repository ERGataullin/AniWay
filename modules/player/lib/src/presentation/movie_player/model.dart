import 'dart:core';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:player/player.dart';

abstract interface class IMoviePlayerModel implements ElementaryModel {
  Future<MovieData> getMovie(Object id);

  Future<List<VideoTranslationData>> getTranslations(Object episodeId);

  Future<void> postTranslationWatched(Object id);
}

class MoviePlayerModel extends ElementaryModel implements IMoviePlayerModel {
  MoviePlayerModel(
    ErrorHandler errorHandler, {
    required PlayerService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  final PlayerService _service;

  @override
  Future<MovieData> getMovie(Object id) {
    return _service.getMovie(id);
  }

  @override
  Future<List<VideoTranslationData>> getTranslations(Object episodeId) {
    return _service.getTranslations(episodeId);
  }

  @override
  Future<void> postTranslationWatched(Object id) {
    return _service.postTranslationWatched(id);
  }
}
