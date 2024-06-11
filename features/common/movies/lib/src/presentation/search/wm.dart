import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/presentation/search/model.dart';

SearchWM searchWMFactory(BuildContext context) => SearchWM(
      SearchModel(
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class ISearchWM implements IWidgetModel {
  ValueListenable<bool> get showLoader;

  ValueListenable<String> get queryHint;

  ValueListenable<List<MovieBaseData>> get movies;

  SearchController get queryController;

  ScrollController get scrollController;

  void onMoviePressed(Object id);
}

class SearchWM extends WidgetModel<SearchWidget, ISearchModel>
    with L10nWMMixin
    implements ISearchWM {
  SearchWM(super._model);

  @override
  late final ComputationNotifier<String> queryHint = ComputationNotifier(
    trigger: l10n,
    computation: () => l10n.value.searchPageTitle,
  );

  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  ValueListenable<List<MovieBaseData>> get movies => model.movies;

  @override
  SearchController get queryController => model.queryController;

  @override
  ScrollController get scrollController => model.scrollController;

  @override
  void didChangeDependencies() {
    model.scrollController = PrimaryScrollController.of(context);
    super.didChangeDependencies();
  }

  @override
  void onMoviePressed(Object id) {
    widget.onMoviePressed(id);
  }

  @override
  void dispose() {
    super.dispose();
    queryHint.dispose();
  }
}
