import 'dart:async';

import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movie_card.dart';
import 'package:app/movies/presentation/search/model.dart';
import 'package:app/movies/presentation/search/widget.dart';
import 'package:flutter/material.dart';

MoviesSearchWM moviesSearchWMFactory(BuildContext context) => MoviesSearchWM(
  MoviesSearchModel(
    errorHandler: context.read<ErrorHandler>(),
    repository: context.read<MoviesRepository>(),
  ),
);

abstract interface class IMoviesSearchWM implements IWidgetModel {
  Computed<String?> get query;

  ScrollController get scrollController;

  Key? get pagedGridKey;

  Future<List<MovieCardData>> handleLoadPage(int page);
}

class MoviesSearchWM extends WidgetModel<MoviesSearchWidget, IMoviesSearchModel>
    with L10nWMMixin
    implements IMoviesSearchWM {
  MoviesSearchWM(super._model);

  @override
  late final Computed<String?> query = Computed(() => widget.query);

  @override
  final GlobalKey<SliverPagedGridState<MovieCardData>> pagedGridKey =
      GlobalKey();

  @override
  ScrollController get scrollController => PrimaryScrollController.of(context);

  @override
  Future<List<MovieCardData>> handleLoadPage(int page) async {
    final List<MovieBaseData> movies = await model.loadPage(
      page: page,
      query: widget.query,
      isOngoing: widget.isOngoing,
    );
    return movies.map(_moviePreviewFromMovie).toList(growable: false);
  }

  @override
  void didUpdateWidget(MoviesSearchWidget oldWidget) {
    if (widget.query != oldWidget.query) {
      query.update();
      pagedGridKey.currentState?.reset();
    }
    super.didUpdateWidget(oldWidget);
  }

  MovieCardData _moviePreviewFromMovie(MovieBaseData movie) {
    return MovieCardData.fromMovie(
      movie,
      l10n: l10n.value,
      onPressed: () => widget.onMoviePressed(movie.id),
    );
  }
}
