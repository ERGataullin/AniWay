import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/presentation/components/movie_preview/model.dart';
import 'package:movies/src/presentation/components/movie_preview/widget.dart';
import 'package:provider/provider.dart';

MoviePreviewWidgetModel moviePreviewWidgetModelFactory(BuildContext context) =>
    MoviePreviewWidgetModel(
      MoviePreviewModel(
        context.read<ErrorHandler>(),
      ),
      webResourcesBaseUri: context.read<Network>().baseUri,
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
  MoviePreviewWidgetModel(
    super._model, {
    required Uri webResourcesBaseUri,
  }) : _webResourcesBaseUri = webResourcesBaseUri;

  @override
  final ValueNotifier<String> posterUrl = ValueNotifier('');

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<String> type = ValueNotifier('');

  @override
  final ValueNotifier<String> score = ValueNotifier('');

  final NumberFormat _scoreFormat = NumberFormat('#0.0');

  final Uri _webResourcesBaseUri;

  MoviePreviewData get _movie => widget.movie;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    posterUrl.value =
        _webResourcesBaseUri.resolveUri(_movie.posterUri).toString();
    title.value = _movie.title;
    score.value = _scoreFormat.format(_movie.score);
  }

  @override
  void didChangeDependencies() {
    type.value = context.localizations.componentsMoviePreviewType(
      _movie.type.name,
    );
  }

  @override
  void dispose() {
    super.dispose();
    posterUrl.dispose();
    title.dispose();
    type.dispose();
    score.dispose();
  }
}
