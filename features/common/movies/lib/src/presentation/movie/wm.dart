import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/presentation/movie/model.dart';

MovieWM movieWMFactory(BuildContext context) => MovieWM(
      MovieModel(
        errorHandler: context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
        network: context.read<Network>(),
      ),
    );

abstract interface class IMovieWM implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<bool> get showLoader;

  ValueListenable<String> get posterUri;

  ValueListenable<String> get description;

  ValueListenable<double?> get score;
}

class MovieWM extends WidgetModel<MovieWidget, IMovieModel>
    implements IMovieWM {
  MovieWM(super._model);

  @override
  late final DynamicData<String> title = DynamicData(
    trigger: model.movie,
    () => model.movie.value?.title ?? '',
  );

  @override
  late final DynamicData<String> description = DynamicData(
    trigger: model.movie,
    () => model.movie.value?.description ?? '',
  );

  //TODO переделать DynamicData<ImageProvider>(см на примере SignInWM)
  @override
  late final DynamicData<String> posterUri = DynamicData(
    trigger: model.poster,
    () => model.poster.value ?? '',
  );

  @override
  late final DynamicData<double?> score = DynamicData(
    trigger: model.movie,
    () => model.movie.value?.score,
  );
  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model.loadData(
      movieId: widget.movieId,
    );
  }

  //TODO добавить dispose
}
