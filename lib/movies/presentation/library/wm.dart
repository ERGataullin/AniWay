import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movie_card.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/presentation/library/model.dart';
import 'package:app/movies/presentation/library/widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

LibraryWM libraryWMFactory(BuildContext context) => LibraryWM(
  LibraryModel(
    errorHandler: context.read<ErrorHandler>(),
    repository: context.read<MoviesRepository>(),
  ),
);

abstract interface class ILibraryWM implements IWidgetModel {
  ValueListenable<List<String>> get tabsTexts;

  List<WatchStatus?> get watchStatuses;

  Future<List<MovieCardData>> handleLoadPage(int page, WatchStatus? statuses);
}

class LibraryWM extends WidgetModel<LibraryWidget, ILibraryModel>
    with L10nWMMixin
    implements ILibraryWM {
  LibraryWM(super._model);
  @override
  late final Computed<List<String>> tabsTexts = Computed(
    () => watchStatuses
        .map(
          (status) =>
              status == null ? 'Все' : l10n.value.watchStatus(status.name),
        )
        .toList(growable: false),
  );

  @override
  List<WatchStatus?> get watchStatuses => [null, ...WatchStatus.values];

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
}
