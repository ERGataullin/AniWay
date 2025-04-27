import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movie_card.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/presentation/library/model.dart';
import 'package:app/movies/presentation/library/widget.dart';
import 'package:flutter/material.dart';

LibraryWM libraryWMFactory(BuildContext context) => LibraryWM(
  LibraryModel(
    errorHandler: context.read<ErrorHandler>(),
    repository: context.read<MoviesRepository>(),
  ),
);

abstract interface class ILibraryWM implements IWidgetModel {
  // ValueListenable<TabController> get tabController;

  // ValueListenable<List<String>> get tabsTexts;

  // ValueListenable<List<List<MovieBaseData>>> get tabsMovies;

  Future<List<MovieCardData>> handleLoadPage(int page, WatchStatus? statuses);
}

class LibraryWM extends WidgetModel<LibraryWidget, ILibraryModel>
    with L10nWMMixin, SingleTickerProviderWidgetModelMixin
    implements ILibraryWM {
  LibraryWM(super._model);

  // @override
  // late final Computed<TabController> tabController = Computed(
  //   () => TabController(length: WatchStatus.values.length, vsync: this),
  // );

  // @override
  // late final Computed<List<String>> tabsTexts = Computed(
  //   () => [null, ...WatchStatus.values]
  //       .map(
  //         (status) =>
  //             status == null ? 'Все' : l10n.value.watchStatus(status.name),
  //       )
  //       .toList(growable: false),
  // );

  @override
  Future<List<MovieCardData>> handleLoadPage(
    int page,
    WatchStatus? status,
  ) async {
    final List<MovieBaseData> movies = await model.getMovies(
      page: page,
      statuses: status == null ? WatchStatus.values : [status],
    );
    return movies
        .map(
          (movie) => MovieCardData.fromMovie(
            movie,
            l10n: l10n.value,
            onPressed: () => widget.onMoviePressed(movie.id),
          ),
        )
        .toList(growable: false);
  }

  // @override
  // late final Computed<List<List<MovieBaseData>>> tabsMovies = Computed(
  //   () => List.generate(WatchStatus.values.length - 1, (index) {
  //     _movies = model.getMovies([_convertIndexToWatchStatus(index)]);
  //     return _movies;
  //   }),
  // );
}
