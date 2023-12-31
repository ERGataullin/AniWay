import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/presentation/movie/widget_model.dart';

class MovieWidget extends ElementaryWidget<IMovieWidgetModel> {
  const MovieWidget({
    super.key,
    WidgetModelFactory wmFactory = movieWidgetModelFactory,
  }) : super(wmFactory);

  @override
  Widget build(IMovieWidgetModel wm) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Some movie'),
      ),
    );
  }
}
