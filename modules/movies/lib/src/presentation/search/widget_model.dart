import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/presentation/search/model.dart';

SearchWidgetModel searchWidgetModelFactory(BuildContext context) =>
    SearchWidgetModel(
      SearchModel(
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class ISearchWidgetModel implements IWidgetModel {
  ValueListenable<bool> get showLoader;

  ValueListenable<String> get queryHint;

  ValueListenable<List<MoviePreviewData>> get movies;

  SearchController get queryController;

  ScrollController get scrollController;

  void onMoviePressed(int id);
}

class SearchWidgetModel extends WidgetModel<SearchWidget, ISearchModel>
    implements ISearchWidgetModel {
  SearchWidgetModel(super._model);

  @override
  final ValueNotifier<String> queryHint = ValueNotifier('');

  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  ValueListenable<List<MoviePreviewData>> get movies => model.movies;

  @override
  SearchController get queryController => model.queryController;

  @override
  ScrollController get scrollController => model.scrollController;

  @override
  void didChangeDependencies() {
    _updateQueryHint();
  }

  @override
  void onMoviePressed(int id) {
    widget.onMoviePressed(id);
  }

  @override
  void dispose() {
    super.dispose();
    queryHint.dispose();
  }

  void _updateQueryHint() {
    queryHint.value = context.localizations.searchSearchBarHint;
  }
}
