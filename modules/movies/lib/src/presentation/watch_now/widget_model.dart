import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/presentation/watch_now/model.dart';

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
  final ValueNotifier<bool> showLoader = ValueNotifier(false);

  @override
  final ValueNotifier<String> upNextLabel = ValueNotifier('');

  @override
  final ValueNotifier<List<UpNextData>> upNextItems = ValueNotifier(const []);

  @override
  final ValueNotifier<String> mostPopularLabel = ValueNotifier('');

  @override
  final ValueNotifier<List<MoviePreviewData>> mostPopularItems =
      ValueNotifier(const []);

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    unawaited(_loadMovies());
  }

  @override
  void didChangeDependencies() {
    title.value = context.localizations.watchNowTitle;
    upNextLabel.value = context.localizations.watchNowUpNextLabel;
    mostPopularLabel.value = context.localizations.watchNowMostPopularLabel;
  }

  @override
  void onUpNextPressed({
    required int movieId,
    required int episodeId,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        barrierDismissible: true,
        builder: (context) => widget.playerBuilder(movieId, episodeId),
      ),
    );
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
    upNextLabel.dispose();
    upNextItems.dispose();
    mostPopularLabel.dispose();
    mostPopularItems.dispose();
  }

  Future<void> _loadMovies() async {
    showLoader.value = true;
    await Future.wait([
      model
          .getUpNextItems()
          .then((items) => upNextItems.value = List.unmodifiable(items)),
      model
          .getMostPopularItems()
          .then((items) => mostPopularItems.value = List.unmodifiable(items)),
    ]);
    showLoader.value = false;
  }
}
