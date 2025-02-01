import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_card.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/presentation/home/model.dart';

HomeWM homeWMFactory(BuildContext context) => HomeWM(
      HomeModel(
        errorHandler: context.read<ErrorHandler>(),
        repository: context.read<MoviesRepository>(),
      ),
    );

abstract interface class IHomeWM implements IWidgetModel {
  ValueListenable<bool> get loading;

  ValueListenable<List<MovieCardData>> get upNextItems;

  ValueListenable<List<MovieCardData>> get ongoingItems;

  ValueListenable<List<MovieCardData>> get popularItems;

  Uri get upNextUri;

  Uri get ongoingsUri;

  Uri get popularsUri;

  Future<void> handleRefresh();
}

class HomeWM extends WidgetModel<HomeWidget, IHomeModel>
    with L10nWMMixin
    implements IHomeWM {
  HomeWM(super._model);

  @override
  late final Computed<List<MovieCardData>> upNextItems = Computed(
    trigger: Listenable.merge([l10n, model.upNext]),
    () =>
        model.upNext.value.map(_moviePreviewFromUpNext).toList(growable: false),
  );

  @override
  late final Computed<List<MovieCardData>> ongoingItems = Computed(
    trigger: Listenable.merge([l10n, model.ongoings]),
    () => model.ongoings.value
        .map(_moviePreviewFromMovie)
        .toList(growable: false),
  );

  @override
  late final Computed<List<MovieCardData>> popularItems = Computed(
    trigger: Listenable.merge([l10n, model.populars]),
    () => model.populars.value
        .map(_moviePreviewFromMovie)
        .toList(growable: false),
  );

  @override
  ValueListenable<bool> get loading => model.loading;

  @override
  Uri get upNextUri => widget.upNextUri;

  @override
  Uri get ongoingsUri => widget.ongoingsUri;

  @override
  Uri get popularsUri => widget.popularsUri;

  @override
  Future<void> handleRefresh() async {
    await model.refresh();
  }

  @override
  void dispose() {
    upNextItems.dispose();
    ongoingItems.dispose();
    popularItems.dispose();
    super.dispose();
  }

  MovieCardData _moviePreviewFromUpNext(UpNextData upNext) {
    return MovieCardData.fromUpNext(
      upNext,
      l10n: l10n.value,
      onPressed: () => widget.onUpNextPressed(
        upNext.movie.id,
        upNext.episode.id,
      ),
      onLongPressed: () => widget.onMoviePressed(upNext.movie.id),
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
