import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/presentation/movie/widget_model.dart';

class MovieWidget extends ElementaryWidget<IMovieWM> {
  const MovieWidget({
    super.key,
    WidgetModelFactory wmFactory = movieWMFactory,
  }) : super(wmFactory);

  @override
  Widget build(IMovieWM wm) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Some movie'),
      ),
    );
  }
}
