import 'dart:async';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/movie_player/model.dart';
import 'package:provider/provider.dart';

MoviePlayerWidgetModel moviePlayerWidgetModelFactory(BuildContext context) =>
    MoviePlayerWidgetModel(
      MoviePlayerModel(
        context.read<ErrorHandler>(),
        service: context.read<PlayerService>(),
      ),
    );

abstract interface class IMoviePlayerWidgetModel implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<Map<VideoTranslationTypeData, List<VideoTranslationData>>>
      get translations;

  void onEpisodeFinished(Object translationId);
}

class MoviePlayerWidgetModel
    extends WidgetModel<MoviePlayerWidget, IMoviePlayerModel>
    with SingleTickerProviderWidgetModelMixin
    implements IMoviePlayerWidgetModel {
  MoviePlayerWidgetModel(super._model);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<Map<VideoTranslationTypeData, List<VideoTranslationData>>>
      translations = ValueNotifier(const {});

  late final MovieData _movie;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    unawaited(_loadMovie());
    unawaited(_loadTranslations());
  }

  @override
  void dispose() {
    super.dispose();
    title.dispose();
    translations.dispose();
  }

  Future<void> _loadMovie() async {
    _movie = await model.getMovie(widget.movieId);
    title.value = _movie.title;
  }

  Future<void> _loadTranslations() async {
    final List<VideoTranslationData> translations =
        await model.getTranslations(widget.episodeId);
    this.translations.value = {
      for (final VideoTranslationTypeData type
          in VideoTranslationTypeData.values)
        type: translations
            .where((translation) => translation.type == type)
            .toList(growable: false),
    };
  }

  @override
  Future<void> onEpisodeFinished(Object translationId) {
    return model.postTranslationWatched(translationId);
  }
}
