import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_base.dart';
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

  ValueListenable<String> get popularLabel;

  ValueListenable<List<MovieBaseData>> get popularItems;

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
  late final ListenableNotifier<String> title = ListenableNotifier(
    l10n,
    () => l10n.value.homePageTitle,
  );

  @override
  late final ListenableNotifier<String> upNextLabel = ListenableNotifier(
    l10n,
    () => l10n.value.upNextLabel,
  );

  @override
  late final ListenableNotifier<String> popularLabel = ListenableNotifier(
    l10n,
    () => l10n.value.popularLabel,
  );

  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  ValueListenable<List<UpNextData>> get upNextItems => model.upNext;

  @override
  ValueListenable<List<MovieBaseData>> get popularItems => model.popular;

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
    popularLabel.dispose();
  }
}
