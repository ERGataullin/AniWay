import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/presentation/components/movie_preview/model.dart';
import 'package:movies/src/presentation/components/movie_preview/widget.dart';

MoviePreviewWM moviePreviewWMFactory(BuildContext context) => MoviePreviewWM(
      MoviePreviewModel(
        context.read<ErrorHandler>(),
        posterBaseUri: context.read<Network>().baseUri,
      ),
    );

abstract interface class IMoviePreviewWM implements IWidgetModel {
  ValueListenable<ImageProvider> get poster;

  ValueListenable<String> get title;

  ValueListenable<String> get type;

  ValueListenable<bool> get showScore;

  ValueListenable<String> get score;
}

class MoviePreviewWM
    extends WidgetModel<MoviePreviewWidget, IMoviePreviewModel>
    implements IMoviePreviewWM {
  MoviePreviewWM(super._model);

  @override
  final ValueNotifier<ImageProvider> poster = ValueNotifier(
    const NetworkImage(''),
  );

  @override
  final ValueNotifier<String> type = ValueNotifier('');

  @override
  final ValueNotifier<bool> showScore = ValueNotifier(false);

  @override
  final ValueNotifier<String> score = ValueNotifier('');

  @override
  ValueListenable<String> get title => model.title;

  final NumberFormat _scoreFormat = NumberFormat('#0.0');

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..posterUri.addListener(_updatePoster)
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
      ..posterUri.removeListener(_updatePoster)
      ..type.removeListener(_updateType)
      ..score.removeListener(_updateScore);
    poster.dispose();
    type.dispose();
    showScore.dispose();
    score.dispose();
  }

  void _updatePoster() {
    poster.value = NetworkImage(model.posterUri.value.toString());
  }

  void _updateType() {
    type.value = context.localizations.moviePreviewType(model.type.value.name);
  }

  void _updateScore() {
    showScore.value = model.score.value != null;
    score.value = _scoreFormat.format(model.score.value);
  }
}
