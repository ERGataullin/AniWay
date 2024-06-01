import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
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

  ValueListenable<List<UpNextData>> get upNextItems;

  ValueListenable<String> get mostPopularLabel;

  ValueListenable<List<MoviePreviewData>> get mostPopularItems;

  void onUpNextPressed({
    required Object movieId,
    required Object episodeId,
  });

  void onMoviePressed(Object id);
}

class HomeWM extends WidgetModel<HomeWidget, IHomeModel>
    with L10nWMMixin
    implements IHomeWM {
  HomeWM(super._model);

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
    required Object movieId,
    required Object episodeId,
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
  void onMoviePressed(Object id) {
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
    title.value = l10n.homePageTitle;
  }

  void _updateUpNextLabel() {
    upNextLabel.value = l10n.upNextLabel;
  }

  void _updateMostPopularLabel() {
    mostPopularLabel.value = l10n.mostPopularLabel;
  }
}
