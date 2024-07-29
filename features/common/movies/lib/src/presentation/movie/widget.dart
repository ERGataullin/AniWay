import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/presentation/movie/wm.dart';

class MovieWidget extends ElementaryWidget<IMovieWM> {
  const MovieWidget({
    super.key,
    required this.movieId,
    WidgetModelFactory wmFactory = movieWMFactory,
  }) : super(wmFactory);

  final int movieId;

  @override
  Widget build(IMovieWM wm) {
    return Provider<IMovieWM>.value(
      value: wm,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          wm.title,
        ]),
        builder: (context, __) => Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(wm.title.value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
