import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/src/presentation/movie/model.dart';
import 'package:movies/src/presentation/movie/widget.dart';

MovieWM movieWMFactory(BuildContext context) => MovieWM(
      MovieModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class IMovieWM implements IWidgetModel {}

class MovieWM extends WidgetModel<MovieWidget, IMovieModel>
    implements IMovieWM {
  MovieWM(super._model);
}
