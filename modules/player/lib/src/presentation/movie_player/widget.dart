import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/movie_player/widget_model.dart';

class MoviePlayerWidget extends ElementaryWidget<IMoviePlayerWidgetModel> {
  const MoviePlayerWidget({
    super.key,
    WidgetModelFactory wmFactory = moviePlayerWidgetModelFactory,
  }) : super(wmFactory);

  @override
  Widget build(IMoviePlayerWidgetModel wm) {
    return const Placeholder();
  }
}
