import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/presentation/movie/model.dart';

MovieWM movieWMFactory(BuildContext context) => MovieWM(
      MovieModel(
        errorHandler: context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class IMovieWM implements IWidgetModel {
}

class MovieWM extends WidgetModel<MovieWidget, IMovieModel>
    implements IMovieWM {
  MovieWM(super._model);

}
