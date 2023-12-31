import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/src/presentation/movie/model.dart';
import 'package:movies/src/presentation/movie/widget.dart';

MovieWidgetModel movieWidgetModelFactory(BuildContext context) =>
    MovieWidgetModel(
      MovieModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class IMovieWidgetModel implements IWidgetModel {}

class MovieWidgetModel extends WidgetModel<MovieWidget, IMovieModel>
    implements IMovieWidgetModel {
  MovieWidgetModel(super._model);
}
