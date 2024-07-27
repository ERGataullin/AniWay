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

  ValueListenable<VoidCallback?> get onPreviousPressed;

  ValueListenable<VoidCallback?> get onNextPressed;

  Future<VideoData> handleResolveVideo(int translationId);

  void handleWatched(int translationId);

  void handleFinished();
}

class MoviePlayerWM extends WidgetModel<MoviePlayerWidget, IMoviePlayerModel>
    with L10nWMMixin
    implements IMoviePlayerWM {
  MoviePlayerWM(super._model);

  @override
  late final DynamicData<String> title = DynamicData(
    trigger: model.movie,
    () => model.movie.value?.title ?? '',
  );

  @override
  late final DynamicData<String> subtitle = DynamicData(
    trigger: Listenable.merge([model.episode, l10n]),
    () => model.episode.value == null
        ? ''
        : l10n.value.movieEpisode(
            model.episode.value!.type.name,
            model.episode.value!.number!,
          ),
  );

  @override
  late final DynamicData<VoidCallback?> onPreviousPressed = DynamicData(
    trigger: model.hasPreviousEpisode,
    () => model.hasPreviousEpisode.value ? model.loadPreviousEpisode : null,
  );

  @override
  late final DynamicData<VoidCallback?> onNextPressed = DynamicData(
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
      episodeId: widget.initialEpisodeId,
    );
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
    subtitle.dispose();
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
