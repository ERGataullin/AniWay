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

  SearchController get searchController;

  ValueListenable<List<MoviePreviewData>> get moviesByQuery;
}

class SearchWidgetModel extends WidgetModel<SearchWidget, ISearchModel>
    implements ISearchWidgetModel {
  SearchWidgetModel(super._model);

  @override
  final ValueNotifier<String> hintText = ValueNotifier('');

  @override
  final SearchController searchController = SearchController();

  @override
  final ValueNotifier<List<MoviePreviewData>> moviesByQuery =
      ValueNotifier(const []);

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    searchController.addListener(_delayInput);
  }

  @override
  void didChangeDependencies() {
    hintText.value = context.localizations.hintText;
  }

  @override
  void dispose() {
    super.dispose();
    hintText.dispose();
    searchController.dispose();
  }

  Timer? _searchTimer;

  void _delayInput() {
    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 300), _loadMoviesByQuery);
  }

  Future<void> _loadMoviesByQuery() async {
    moviesByQuery.value = const [];
    await model
        .getMoviesByQuery(searchController.text)
        .then((items) => moviesByQuery.value = List.unmodifiable(items));
  }
}
