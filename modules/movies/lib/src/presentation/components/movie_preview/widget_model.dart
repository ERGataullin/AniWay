import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/presentation/components/movie_preview/model.dart';
import 'package:movies/src/presentation/components/movie_preview/widget.dart';
import 'package:provider/provider.dart';

MoviePreviewWidgetModel moviePreviewWidgetModelFactory(BuildContext context) =>
    MoviePreviewWidgetModel(
      MoviePreviewModel(
        context.read<ErrorHandler>(),
        posterBaseUri: context.read<Network>().baseUri,
      ),
    );

abstract interface class IMoviePreviewWidgetModel implements IWidgetModel {
  ValueListenable<String> get posterUrl;

  ValueListenable<String> get title;

  ValueListenable<String> get type;

  ValueListenable<String> get score;
}

class MoviePreviewWidgetModel
    extends WidgetModel<MoviePreviewWidget, IMoviePreviewModel>
    implements IMoviePreviewWidgetModel {
  MoviePreviewWidgetModel(super._model);

  @override
  final ValueNotifier<String> posterUrl = ValueNotifier('');

  @override
  final ValueNotifier<String> type = ValueNotifier('');

  @override
  final ValueNotifier<String> score = ValueNotifier('');

  @override
  ValueListenable<String> get title => model.title;

  final NumberFormat _scoreFormat = NumberFormat('#0.0');

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..posterUri.addListener(_updatePosterUrl)
      ..type.addListener(_updateType)
      ..score.addListener(_updateScore)
      ..movie = widget.movie;
  }

  @override
  void didChangeDependencies() {
    _updateType();
  }

  @override
  void didUpdateWidget(MoviePreviewWidget oldWidget) {
    model.movie = widget.movie;
  }

  @override
  void dispose() {
    super.dispose();
    model
      ..posterUri.removeListener(_updatePosterUrl)
      ..type.removeListener(_updateType)
      ..score.removeListener(_updateScore);
    posterUrl.dispose();
    type.dispose();
    score.dispose();
  }

  void _updatePosterUrl() {
    posterUrl.value = model.posterUri.value.toString();
  }

  void _updateType() {
    type.value = context.localizations.moviePreviewType(model.type.value.name);
  }

  void _updateScore() {
    score.value = _scoreFormat.format(model.score.value);
  }
}
