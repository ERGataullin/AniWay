import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/presentation/watch_now/model.dart';
import 'package:provider/provider.dart';

WatchNowWidgetModel watchNowWidgetModelFactory(BuildContext context) =>
    WatchNowWidgetModel(
      WatchNowModel(
        context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class IWatchNowWidgetModel implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<bool> get showLoader;

  ValueListenable<String> get upNextLabel;

  ValueListenable<List<UpNextData>> get upNextItems;

  ValueListenable<String> get mostPopularLabel;

  ValueListenable<List<MoviePreviewData>> get mostPopularItems;

  void onUpNextPressed({
    required int movieId,
    required int episodeId,
  });

  void onMoviePressed(int id);
}

class WatchNowWidgetModel extends WidgetModel<WatchNowWidget, IWatchNowModel>
    implements IWatchNowWidgetModel {
  WatchNowWidgetModel(super._model);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<String> upNextLabel = ValueNotifier('');

  @override
  final ValueNotifier<String> mostPopularLabel = ValueNotifier('');

  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  ValueListenable<List<UpNextData>> get upNextItems => model.upNext;

  @override
  ValueListenable<List<MoviePreviewData>> get mostPopularItems =>
      model.mostPopular;

  @override
  void didChangeDependencies() {
    _updateTitle();
    _updateUpNextLabel();
    _updateMostPopularLabel();
  }

  @override
  void onUpNextPressed({
    required int movieId,
    required int episodeId,
  }) {
    widget.onUpNextPressed(movieId, episodeId);
  }

  @override
  void onMoviePressed(int id) {
    widget.onMoviePressed(id);
  }

  @override
  void dispose() {
    super.dispose();
    title.dispose();
    upNextLabel.dispose();
    mostPopularLabel.dispose();
  }

  void _updateTitle() {
    title.value = context.localizations.watchNowTitle;
  }

  void _updateUpNextLabel() {
    upNextLabel.value = context.localizations.watchNowUpNextLabel;
  }

  void _updateMostPopularLabel() {
    mostPopularLabel.value = context.localizations.watchNowMostPopularLabel;
  }
}
