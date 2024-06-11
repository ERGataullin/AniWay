import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/presentation/components/movie_player/wm.dart';
import 'package:player/player.dart';

class MoviePlayerWidget extends ElementaryWidget<IMoviePlayerWM> {
  const MoviePlayerWidget({
    super.key,
    required this.movieId,
    required this.episodeId,
    WidgetModelFactory wmFactory = moviePlayerWMFactory,
  }) : super(wmFactory);

  final Object movieId;

  final Object episodeId;

  @override
  Widget build(IMoviePlayerWM wm) {
    return Provider<IMoviePlayerWM>.value(
      value: wm,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          wm.title,
          wm.subtitle,
          wm.translations,
        ]),
        builder: (context, __) => VideoPlayerWidget(
          title: wm.title.value,
          subtitle: wm.subtitle.value,
          translations: wm.translations.value,
          videoResolver: wm.onResolveVideo,
          onPreviousPressed: wm.onPreviousPressed,
          onNextPressed: wm.onNextPressed,
          onWatched: wm.onWatched,
          onFinished: wm.onFinished,
        ),
      ),
    );
  }
}
