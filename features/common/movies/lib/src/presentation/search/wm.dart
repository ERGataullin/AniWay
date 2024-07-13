import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/presentation/search/model.dart';

SearchWM searchWMFactory(BuildContext context) => SearchWM(
      SearchModel(
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class ISearchWM implements IWidgetModel {
  ValueListenable<bool> get showLoader;

  ValueListenable<bool> get centerLoader;

  ValueListenable<String> get queryHint;

  ValueListenable<List<MoviePreviewData>> get movies;

  SearchController get queryController;

  ScrollController get scrollController;
}

class SearchWM extends WidgetModel<SearchWidget, ISearchModel>
    with L10nWMMixin
    implements ISearchWM {
  SearchWM(super._model);

  @override
  late final DynamicData<bool> centerLoader = DynamicData(
    trigger: model.movies,
    () => model.movies.value.isEmpty,
  );

  @override
  late final DynamicData<String> queryHint = DynamicData(
    trigger: l10n,
    () => l10n.value.searchPageTitle,
  );

  @override
  late final DynamicData<List<MoviePreviewData>> movies = DynamicData(
    trigger: Listenable.merge([l10n, model.movies]),
    () => model.movies.value
        .map(
          (movie) => MoviePreviewData.fromMovie(
            movie,
            l10n: l10n.value,
            onPressed: () => widget.onMoviePressed(movie.id),
          ),
        )
        .toList(growable: false),
  );

  @override
  ValueListenable<bool> get showLoader => model.loading;

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
  void dispose() {
    super.dispose();
    centerLoader.dispose();
    queryHint.dispose();
    movies.dispose();
  }
}
