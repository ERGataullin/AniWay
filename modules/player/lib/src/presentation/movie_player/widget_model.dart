import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/widgets.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/movie_player/model.dart';
import 'package:provider/provider.dart';

MoviePlayerWidgetModel moviePlayerWidgetModelFactory(BuildContext context) =>
    MoviePlayerWidgetModel(
      MoviePlayerModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class IMoviePlayerWidgetModel implements IWidgetModel {}

class MoviePlayerWidgetModel
    extends WidgetModel<MoviePlayerWidget, IMoviePlayerModel>
    implements IMoviePlayerWidgetModel {
  MoviePlayerWidgetModel(super._model);
}
