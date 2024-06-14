import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/presentation/components/movie_player/model.dart';
import 'package:player/player.dart';

MoviePlayerWM moviePlayerWMFactory(BuildContext context) => MoviePlayerWM(
      MoviePlayerModel(
        context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class IMoviePlayerWM implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  ValueListenable<List<VideoTranslationData>> get translations;

  Future<VideoData> onResolveVideo(Object translationId);

  void onPreviousPressed();

  void onNextPressed();

  void onWatched(Object translationId);

  void onFinished();
}

class MoviePlayerWM extends WidgetModel<MoviePlayerWidget, IMoviePlayerModel>
    with L10nWMMixin
    implements IMoviePlayerWM {
  MoviePlayerWM(super._model);

  @override
  late final ComputationNotifier<String> title = ComputationNotifier(
    trigger: model.movie,
    () => model.movie.value?.title ?? '',
  );

  @override
  late final ComputationNotifier<String> subtitle = ComputationNotifier(
    trigger: Listenable.merge([model.episode, l10n]),
    () => model.episode.value == null
        ? ''
        : l10n.value.movieEpisode(
            model.episode.value!.type.name,
            model.episode.value!.number!,
          ),
  );

  @override
  ValueListenable<List<VideoTranslationData>> get translations =>
      model.translations;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model.loadData(
      movieId: widget.movieId,
      episodeId: widget.episodeId,
    );
    if (!kIsWeb) {
      _lockOrientation();
    }
  }

  @override
  Future<VideoData> onResolveVideo(Object translationId) {
    return model.getVideo(translationId);
  }

  @override
  void onPreviousPressed() {
    model.loadPreviousEpisode();
  }

  @override
  void onNextPressed() {
    model.loadNextEpisode();
  }

  @override
  void onWatched(Object translationId) {
    model.saveTranslationWatched(translationId);
  }

  @override
  void onFinished() {
    model.loadNextEpisode();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    title.dispose();
    subtitle.dispose();
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
