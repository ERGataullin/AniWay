import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/video_player/widget.dart';
import 'package:player/src/presentation/movie_player/widget_model.dart';

class MoviePlayerWidget extends ElementaryWidget<IMoviePlayerWidgetModel> {
  const MoviePlayerWidget({
    super.key,
    required this.movieId,
    required this.episodeId,
    WidgetModelFactory wmFactory = moviePlayerWidgetModelFactory,
  }) : super(wmFactory);

  final Object movieId;

  final Object episodeId;

  @override
  Widget build(IMoviePlayerWidgetModel wm) {
    return Provider<IMoviePlayerWidgetModel>.value(
      value: wm,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          wm.title,
          wm.subtitle,
          wm.preferences,
        ]),
        builder: (context, __) => VideoPlayerWidget(
          controller: wm.controller,
          title: wm.title.value,
          subtitle: wm.subtitle.value,
          preferences: wm.preferences.value,
          onPreviousPressed: wm.onPreviousPressed,
          onNextPressed: wm.onNextPressed,
        ),
      ),
    );
  }
}
