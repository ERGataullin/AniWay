import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/presentation/movie/model.dart';

MovieWM movieWMFactory(BuildContext context) => MovieWM(
      MovieModel(
        errorHandler: context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
      ),
      posterBaseUri: context.read<Network>().baseUri,
    );

abstract interface class IMovieWM implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<bool> get showLoader;

  ValueListenable<ImageProvider?> get poster;

  ValueListenable<String> get description;

  ValueListenable<double?> get score;
}

class MovieWM extends WidgetModel<MovieWidget, IMovieModel>
    implements IMovieWM {
  MovieWM(
    super._model, {
    required Uri posterBaseUri,
  }) : _posterBaseUri = posterBaseUri;

  final Uri _posterBaseUri;

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

  @override
  late final DynamicData<ImageProvider?> poster = DynamicData(
    trigger: model.movie,
    () => model.movie.value == null
        ? null
        : NetworkImage(
            _posterBaseUri.resolveUri(model.movie.value!.posterUri).toString(),
          ),
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
