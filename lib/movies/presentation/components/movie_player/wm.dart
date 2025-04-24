import 'dart:async';

import 'package:app/core/core.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/episode.dart';
import 'package:app/movies/presentation/components/movie_player/model.dart';
import 'package:app/movies/presentation/components/movie_player/widget.dart';
import 'package:app/player/player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

MoviePlayerWM moviePlayerWMFactory(BuildContext context) => MoviePlayerWM(
  MoviePlayerModel(
    context.read<ErrorHandler>(),
    repository: context.read<MoviesRepository>(),
  ),
);

abstract interface class IMoviePlayerWM implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<EpisodeData?> get episode;

  ValueListenable<List<TranslationData>> get translations;

  ValueListenable<VoidCallback?> get onPreviousPressed;

  ValueListenable<VoidCallback?> get onNextPressed;

  Future<VideoData> handleResolveVideo(int translationId);

  void handleWatched(int translationId);

  void handleFinished();
}

class MoviePlayerWM extends WidgetModel<MoviePlayerWidget, IMoviePlayerModel>
    implements IMoviePlayerWM {
  MoviePlayerWM(super._model);

  @override
  late final Computed<String> title = Computed(
    trigger: model.movie,
    () => model.movie.value?.title ?? '',
  );

  @override
  late final Computed<VoidCallback?> onPreviousPressed = Computed(
    trigger: model.hasPreviousEpisode,
    () => model.hasPreviousEpisode.value ? model.loadPreviousEpisode : null,
  );

  @override
  late final Computed<VoidCallback?> onNextPressed = Computed(
    trigger: model.hasNextEpisode,
    () => model.hasNextEpisode.value ? model.loadNextEpisode : null,
  );

  @override
  ValueListenable<EpisodeData?> get episode => model.episode;

  @override
  ValueListenable<List<TranslationData>> get translations => model.translations;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model.loadData(movieId: widget.movieId, episodeId: widget.initialEpisodeId);
    if (!kIsWeb) {
      _lockOrientation();
    }
  }

  @override
  Future<VideoData> handleResolveVideo(int translationId) {
    return model.getVideo(translationId);
  }

  @override
  void handleWatched(int translationId) {
    model.saveTranslationWatched(translationId);
  }

  @override
  void handleFinished() {
    model.hasNextEpisode.value
        ? model.loadNextEpisode()
        : Navigator.pop(context);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    title.dispose();
    onPreviousPressed.dispose();
    onNextPressed.dispose();
    if (!kIsWeb) {
      await _unlockOrientation();
    }
  }

  Future<void> _lockOrientation() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _unlockOrientation() {
    return SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }
}
