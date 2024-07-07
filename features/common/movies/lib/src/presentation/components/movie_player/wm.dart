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

  ValueListenable<VoidCallback?> get previousCallback;

  ValueListenable<VoidCallback?> get nextCallback;

  Future<VideoData> onResolveVideo(Object translationId);

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
  late final ComputationNotifier<VoidCallback?> previousCallback =
      ComputationNotifier(
    trigger: model.hasPreviousEpisode,
    () => model.hasPreviousEpisode.value ? model.loadPreviousEpisode : null,
  );

  @override
  late final ComputationNotifier<VoidCallback?> nextCallback =
      ComputationNotifier(
    trigger: model.hasNextEpisode,
    () => model.hasNextEpisode.value ? model.loadNextEpisode : null,
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
  void onWatched(Object translationId) {
    model.saveTranslationWatched(translationId);
  }

  @override
  void onFinished() {
    model.hasNextEpisode.value
        ? model.loadNextEpisode()
        : Navigator.pop(context);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    title.dispose();
    subtitle.dispose();
    previousCallback.dispose();
    nextCallback.dispose();
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
