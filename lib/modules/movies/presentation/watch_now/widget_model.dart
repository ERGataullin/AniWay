import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/app/domain/services/error_handle/service.dart';
import '/app/localizations.dart';
import '/modules/movies/domain/models/movie_preview.dart';
import '/modules/movies/domain/service/service.dart';
import '/modules/movies/presentation/watch_now/model.dart';
import '/modules/movies/presentation/watch_now/widget.dart';

WatchNowWidgetModel watchNowWidgetModelFactory(BuildContext context) =>
    WatchNowWidgetModel(
      WatchNowModel(
        context.read<ErrorHandleService>(),
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class IWatchNowWidgetModel implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<bool> get showLoader;

  ValueListenable<String> get upNextLabel;

  ValueListenable<List<MoviePreviewData>> get upNextMovies;

  ValueListenable<String> get mostPopularLabel;

  ValueListenable<List<MoviePreviewData>> get mostPopularMovies;

  void onMoviePressed(int id);
}

class WatchNowWidgetModel extends WidgetModel<WatchNowWidget, IWatchNowModel>
    implements IWatchNowWidgetModel {
  WatchNowWidgetModel(super._model);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<bool> showLoader = ValueNotifier(false);

  @override
  final ValueNotifier<String> upNextLabel = ValueNotifier('');

  @override
  final ValueNotifier<List<MoviePreviewData>> upNextMovies =
      ValueNotifier(const []);

  @override
  final ValueNotifier<String> mostPopularLabel = ValueNotifier('');

  @override
  final ValueNotifier<List<MoviePreviewData>> mostPopularMovies =
      ValueNotifier(const []);

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    unawaited(_loadMovies());
  }

  @override
  void didChangeDependencies() {
    title.value = context.localizations.moviesWatchNowTitle;
    upNextLabel.value = context.localizations.moviesWatchNowUpNextLabel;
    mostPopularLabel.value =
        context.localizations.moviesWatchNowMostPopularLabel;
  }

  @override
  void onMoviePressed(int id) {
    widget.onMoviePressed(id);
  }

  @override
  void dispose() {
    super.dispose();
    title.dispose();
    showLoader.dispose();
    upNextMovies.dispose();
  }

  Future<void> _loadMovies() async {
    showLoader.value = true;
    await Future.wait([
      model.getUpNextMovies().then((movies) => upNextMovies.value = movies),
      model
          .getMostPopularMovies()
          .then((movies) => mostPopularMovies.value = movies),
    ]);
    showLoader.value = false;
  }
}
