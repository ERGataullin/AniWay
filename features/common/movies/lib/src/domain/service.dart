import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/data/dto/movie_base.dart';
import 'package:movies/src/data/dto/movie_details.dart';
import 'package:movies/src/data/dto/up_next.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_details.dart';
import 'package:movies/src/domain/models/movies_order.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/watch_status.dart';
import 'package:player/player.dart';

class MoviesService implements Initable {
  MoviesService({
    required MoviesRepository repository,
  }) : _repository = repository;

  final ValueNotifier<int> _upNextChanges = ValueNotifier(0);

  final MoviesRepository _repository;

  Listenable get upNextChanges => _upNextChanges;

  @override
  void init() {}

  @override
  void dispose() {
    _upNextChanges.dispose();
  }

  Future<List<MovieBaseData>> getMovies({
    int page = 1,
    int limit = 50,
    MoviesOrder order = MoviesOrder.byPopularity,
    String? query,
    List<WatchStatus> watchStatuses = const [],
  }) async {
    final List<MovieBaseDto> dtos = await _repository.getMovies(
      query: query,
      limit: limit,
      offset: (page - 1) * limit,
      order: order.toDto(),
      watchStatus: watchStatuses
          .map((watchStatus) => watchStatus.toDto())
          .toList(growable: false),
    );

    return dtos.map(MovieBaseData.fromDto).toList(growable: false);
  }

  Future<List<UpNextData>> getUpNext({int page = 1}) async {
    final List<UpNextDto> dtos = await _repository.getUpNext(page: page);
    return dtos.map(UpNextData.fromDto).toList(growable: false);
  }

  Future<MovieDetailsData> getMovie(int id) async {
    final MovieDetailsDto dto = await _repository.getMovie(id);
    return MovieDetailsData.fromDto(dto);
  }

  Future<List<VideoTranslationData>> getTranslations(int episodeId) async {
    final List<VideoTranslationDto> dtos = await _repository.getTranslations(
      episodeId,
    );
    return dtos.map(VideoTranslationData.fromDto).toList(growable: false);
  }

  Future<VideoData> getTranslationVideo(int translationId) async {
    final VideoDto dto = await _repository.getTranslationVideo(translationId);
    return VideoData.fromDto(dto);
  }

  Future<void> saveTranslationWatched(int translationId) async {
    await _repository.saveTranslationWatched(translationId);
    _upNextChanges.value++;
  }
}
