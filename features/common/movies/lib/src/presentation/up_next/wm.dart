import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_card.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/presentation/up_next/model.dart';

UpNextWM upNextWMFactory(BuildContext context) => UpNextWM(
      UpNextModel(
        errorHandler: context.read<ErrorHandler>(),
        repository: context.read<MoviesRepository>(),
      ),
    );

abstract interface class IUpNextWM implements IWidgetModel {
  ValueListenable<String> get title;

  ScrollController get scrollController;

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
  late final Computed<String> title = Computed(
    trigger: l10n,
    () => l10n.value.upNextTitle,
  );

  @override
  ScrollController get scrollController => PrimaryScrollController.of(context);

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
    title.dispose();
    super.dispose();
  }

  void _handleChanged() {
    pagedGridKey.currentState?.reset();
  }

  MovieCardData _moviePreviewFromUpNext(UpNextData upNext) {
    return MovieCardData.fromUpNext(
      upNext,
      l10n: l10n.value,
      onPressed: () => widget.onItemPressed(
        upNext.movie.id,
        upNext.episode.id,
      ),
      onLongPressed: () => widget.onItemLongPressed(
        upNext.movie.id,
        upNext.episode.id,
      ),
    );
  }
}
