import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';

import '/modules/movies/presentation/movie/widget_model.dart';

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
