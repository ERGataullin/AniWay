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
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class IHomeWM implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<bool> get showLoader;

  ValueListenable<String> get upNextTitle;

  ValueListenable<List<MovieCardData>> get upNextItems;

  ValueListenable<String> get ongoingTitle;

  ValueListenable<List<MovieCardData>> get ongoingItems;

  ValueListenable<String> get popularTitle;

  ValueListenable<List<MovieCardData>> get popularItems;

  Uri get upNextUri;

  Uri get ongoingUri;

  Uri get popularUri;
}

class HomeWM extends WidgetModel<HomeWidget, IHomeModel>
    with L10nWMMixin
    implements IHomeWM {
  HomeWM(super._model);

  @override
  late final DynamicData<String> title = DynamicData(
    trigger: l10n,
    () => l10n.value.homePageTitle,
  );

  @override
  late final DynamicData<String> upNextTitle = DynamicData(
    trigger: l10n,
    () => l10n.value.upNextTitle,
  );

  @override
  late final DynamicData<String> ongoingTitle = DynamicData(
    trigger: l10n,
    () => l10n.value.ongoingTitle,
  );

  @override
  late final DynamicData<String> popularTitle = DynamicData(
    trigger: l10n,
    () => l10n.value.popularTitle,
  );

  @override
  late final DynamicData<List<MovieCardData>> upNextItems = DynamicData(
    trigger: Listenable.merge([l10n, model.upNext]),
    () =>
        model.upNext.value.map(_moviePreviewFromUpNext).toList(growable: false),
  );

  @override
  late final DynamicData<List<MovieCardData>> ongoingItems = DynamicData(
    trigger: Listenable.merge([l10n, model.ongoing]),
    () => model.ongoing.value
        .map(_moviePreviewFromMovie)
        .toList(growable: false),
  );

  @override
  late final DynamicData<List<MovieCardData>> popularItems = DynamicData(
    trigger: Listenable.merge([l10n, model.popular]),
    () =>
        model.popular.value.map(_moviePreviewFromMovie).toList(growable: false),
  );

  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  Uri get upNextUri => widget.upNextUri;

  @override
  Uri get ongoingUri => widget.ongoingUri;

  @override
  Uri get popularUri => widget.popularUri;

  @override
  void dispose() {
    super.dispose();
    title.dispose();
    upNextTitle.dispose();
    upNextItems.dispose();
    popularTitle.dispose();
    popularItems.dispose();
  }

  MovieCardData _moviePreviewFromUpNext(UpNextData upNext) {
    return MovieCardData.fromUpNext(
      upNext,
      l10n: l10n.value,
      onPressed: () => widget.onUpNextPressed(
        upNext.movie.id,
        upNext.episode.id,
      ),
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
