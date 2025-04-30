import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/movie_card.dart';
import 'package:app/movies/domain/models/up_next.dart';
import 'package:app/movies/presentation/up_next/model.dart';
import 'package:app/movies/presentation/up_next/widget.dart';
import 'package:flutter/widgets.dart';

UpNextWM upNextWMFactory(BuildContext context) => UpNextWM(
  UpNextModel(
    errorHandler: context.read<ErrorHandler>(),
    repository: context.read<MoviesRepository>(),
  ),
);

abstract interface class IUpNextWM implements IWidgetModel {
  Key? get pagedGridKey;

  Future<List<MovieCardData>> handleLoadPage(int page);
}

class UpNextWM extends WidgetModel<UpNextWidget, IUpNextModel>
    with L10nWMMixin
    implements IUpNextWM {
  UpNextWM(super._model);

  @override
  final GlobalKey<SliverPagedGridState<MovieCardData>> pagedGridKey =
      GlobalKey();

  @override
  Future<List<MovieCardData>> handleLoadPage(int page) async {
    final List<UpNextData> movies = await model.loadPage(page: page);
    return movies.map(_moviePreviewFromUpNext).toList(growable: false);
  }

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model.addListener(_handleChanged);
  }

  @override
  void dispose() {
    model.removeListener(_handleChanged);
    super.dispose();
  }

  void _handleChanged() {
    pagedGridKey.currentState?.reset();
  }

  MovieCardData _moviePreviewFromUpNext(UpNextData upNext) {
    return MovieCardData.fromUpNext(
      upNext,
      l10n: l10n.value,
      onPressed: () => widget.onItemPressed(upNext.movie.id, upNext.episode.id),
      onLongPressed:
          () => widget.onItemLongPressed(upNext.movie.id, upNext.episode.id),
    );
  }
}
