import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/episode.dart';
import 'package:app/movies/presentation/components/movie_player/wm.dart';
import 'package:app/player/player.dart';
import 'package:flutter/material.dart';

class MoviePlayerWidget extends ElementaryWidget<IMoviePlayerWM> {
  const MoviePlayerWidget({
    super.key,
    required this.movieId,
    this.initialEpisodeId,
    WidgetModelFactory wmFactory = moviePlayerWMFactory,
  }) : super(wmFactory);

  final int movieId;

  final int? initialEpisodeId;

  @override
  Widget build(IMoviePlayerWM wm) {
    return Provider<IMoviePlayerWM>.value(
      value: wm,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          wm.title,
          wm.episode,
          wm.translations,
          wm.onPreviousPressed,
          wm.onNextPressed,
        ]),
        builder:
            (context, _) => VideoPlayerWidget(
              title: wm.title.value,
              subtitle: switch (wm.episode.value) {
                final EpisodeData episode => context.l10n.movieEpisode(
                  episode.type.name,
                  episode.number!,
                ),
                _ => '',
              },
              translations: wm.translations.value,
              videoResolver: wm.handleResolveVideo,
              onPreviousPressed: wm.onPreviousPressed.value,
              onNextPressed: wm.onNextPressed.value,
              onWatched: wm.handleWatched,
              onFinished: wm.handleFinished,
            ),
      ),
    );
  }
}
