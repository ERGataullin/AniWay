import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/components/video_player/widget.dart';
import 'package:player/src/presentation/movie_player/widget_model.dart';
import 'package:provider/provider.dart';

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
      child: ValueListenableBuilder<String>(
        valueListenable: wm.title,
        builder: (context, title, ___) => ValueListenableBuilder<
            Map<VideoTranslationTypeData, List<VideoTranslationData>>>(
          valueListenable: wm.translations,
          builder: (context, translations, ___) =>
              VideoPlayerWidget.fromTranslations(
            title: title,
            translations: translations,
          ),
        ),
      ),
    );
  }
}
