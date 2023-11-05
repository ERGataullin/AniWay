import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/modules/movies/presentation/movie/model.dart';
import '/modules/movies/presentation/movie/widget.dart';

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
