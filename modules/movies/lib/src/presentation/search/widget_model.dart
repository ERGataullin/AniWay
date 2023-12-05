import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/presentation/search/model.dart';
import 'package:provider/provider.dart';

SearchWidgetModel searchWidgetModelFactory(BuildContext context) =>
    SearchWidgetModel(
      SearchModel(
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class ISearchWidgetModel implements IWidgetModel {
  ValueListenable<String> get hintText;

  ValueListenable<List<MoviePreviewData>> get movies;

  SearchController get queryController;

  void onMoviePressed(int id);
}

class SearchWidgetModel extends WidgetModel<SearchWidget, ISearchModel>
    implements ISearchWidgetModel {
  SearchWidgetModel(super._model);

  @override
  final ValueNotifier<String> hintText = ValueNotifier('');

  @override
  final ValueNotifier<List<MoviePreviewData>> movies = ValueNotifier(const []);

  @override
  final SearchController queryController = SearchController();

  static const Duration _queryDebounceInterval = Duration(milliseconds: 300);

  Timer? _queryDebounceTimer;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    queryController.addListener(_onQueryChanged);
  }

  @override
  void didChangeDependencies() {
    hintText.value = context.localizations.searchSearchBarHint;
  }

  @override
  void onMoviePressed(int id) {
    widget.onMoviePressed(id);
  }

  @override
  void dispose() {
    super.dispose();
    hintText.dispose();
    queryController.dispose();
  }

  void _onQueryChanged() {
    _queryDebounceTimer?.cancel();
    _queryDebounceTimer = Timer(_queryDebounceInterval, _loadMovies);
  }

  Future<void> _loadMovies() async {
    movies.value = const [];
    movies.value = await model.getMovies(
      query: queryController.text,
    );
  }
}
