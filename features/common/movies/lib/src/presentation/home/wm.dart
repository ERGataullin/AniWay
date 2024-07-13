import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/presentation/home/model.dart';

HomeWM homeWMFactory(BuildContext context) => HomeWM(
      HomeModel(
        context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class IHomeWM implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<bool> get showLoader;

  ValueListenable<String> get upNextLabel;

  ValueListenable<List<MoviePreviewData>> get upNextItems;

  ValueListenable<String> get popularLabel;

  ValueListenable<List<MoviePreviewData>> get popularItems;
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
  late final DynamicData<String> upNextLabel = DynamicData(
    trigger: l10n,
    () => l10n.value.upNextLabel,
  );

  @override
  late final DynamicData<String> popularLabel = DynamicData(
    trigger: l10n,
    () => l10n.value.popularLabel,
  );

  @override
  late final DynamicData<List<MoviePreviewData>> upNextItems = DynamicData(
    trigger: Listenable.merge([l10n, model.upNext]),
    () =>
        model.upNext.value.map(_moviePreviewFromUpNext).toList(growable: false),
  );

  @override
  late final DynamicData<List<MoviePreviewData>> popularItems = DynamicData(
    trigger: Listenable.merge([l10n, model.popular]),
    () =>
        model.popular.value.map(_moviePreviewFromMovie).toList(growable: false),
  );

  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  void dispose() {
    super.dispose();
    title.dispose();
    upNextLabel.dispose();
    upNextItems.dispose();
    popularLabel.dispose();
    popularItems.dispose();
  }

  MoviePreviewData _moviePreviewFromUpNext(UpNextData upNext) {
    return MoviePreviewData.fromUpNext(
      upNext,
      l10n: l10n.value,
      onPressed: () => widget.onUpNextPressed(
        upNext.movie.id,
        upNext.episode.id,
      ),
    );
  }

  MoviePreviewData _moviePreviewFromMovie(MovieBaseData movie) {
    return MoviePreviewData.fromMovie(
      movie,
      l10n: l10n.value,
      onPressed: () => widget.onMoviePressed(movie.id),
    );
  }
}
