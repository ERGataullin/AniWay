import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_card.dart';
import 'package:movies/src/presentation/search/model.dart';

MoviesSearchWM moviesSearchWMFactory(BuildContext context) => MoviesSearchWM(
      MoviesSearchModel(
        errorHandler: context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class IMoviesSearchWM implements IWidgetModel {
  ValueListenable<String> get queryHint;

  ValueListenable<bool> get showClearButton;

  SearchController get queryController;

  ScrollController get scrollController;

  Key? get pagedGridKey;

  bool get showBackButton;

  Future<List<MovieCardData>> handleLoadPage(int page);

  void handleClearPressed();
}

class MoviesSearchWM extends WidgetModel<MoviesSearchWidget, IMoviesSearchModel>
    with L10nWMMixin
    implements IMoviesSearchWM {
  MoviesSearchWM(super._model);

  static const Duration _queryDebounceInterval = Durations.medium2;

  @override
  final SearchController queryController = SearchController();

  @override
  late final Computed<String> queryHint = Computed(
    trigger: l10n,
    () => l10n.value.searchPageTitle,
  );

  @override
  late final Computed<bool> showClearButton = Computed(
    trigger: queryController,
    () => queryController.text.isEmpty,
  );

  @override
  final GlobalKey<SliverPagedGridState<MovieCardData>> pagedGridKey =
      GlobalKey();

  String _query = '';

  Timer? _queryDebounceTimer;

  @override
  ScrollController get scrollController => PrimaryScrollController.of(context);

  @override
  bool get showBackButton => Navigator.canPop(context);

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    queryController.addListener(_handleQueryChanged);
  }

  @override
  Future<List<MovieCardData>> handleLoadPage(int page) async {
    final List<MovieBaseData> movies = await model.loadPage(
      page: page,
      query: queryController.text,
      isOngoing: widget.isOngoing,
    );
    return movies.map(_moviePreviewFromMovie).toList(growable: false);
  }

  @override
  void handleClearPressed() {
    queryController.clear();
  }

  @override
  void dispose() {
    _queryDebounceTimer?.cancel();
    queryController.dispose();
    queryHint.dispose();
    super.dispose();
  }

  void _handleQueryChanged() {
    if (_query == queryController.text) return;
    _query = queryController.text;
    _queryDebounceTimer?.cancel();
    _queryDebounceTimer = Timer(
      _queryDebounceInterval,
      () => pagedGridKey.currentState?.reset(),
    );
  }

  MovieCardData _moviePreviewFromMovie(MovieBaseData movie) {
    return MovieCardData.fromMovie(
      movie,
      l10n: l10n.value,
      onPressed: () => widget.onMoviePressed(movie.id),
    );
  }
}
