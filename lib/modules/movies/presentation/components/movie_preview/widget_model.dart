import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/app/domain/services/error_handle/service.dart';
import '/app/domain/services/network/service.dart';
import '/app/localizations.dart';
import '/modules/movies/domain/models/movie_preview.dart';
import '/modules/movies/presentation/components/movie_preview/model.dart';
import '/modules/movies/presentation/components/movie_preview/widget.dart';

MoviePreviewWidgetModel moviePreviewWidgetModelFactory(BuildContext context) =>
    MoviePreviewWidgetModel(
      MoviePreviewModel(
        context.read<ErrorHandleService>(),
      ),
      webResourcesBaseUri: context.read<NetworkService>().baseUri,
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
    type.value = switch (_movie.type) {
      MovieTypeData.tv =>
        context.localizations.moviesComponentsMoviePreviewTypeTv,
      MovieTypeData.movie =>
        context.localizations.moviesComponentsMoviePreviewTypeMovie,
      MovieTypeData.ova =>
        context.localizations.moviesComponentsMoviePreviewTypeOva,
      MovieTypeData.ona =>
        context.localizations.moviesComponentsMoviePreviewTypeOna,
      MovieTypeData.special =>
        context.localizations.moviesComponentsMoviePreviewTypeSpecial,
      MovieTypeData.music =>
        context.localizations.moviesComponentsMoviePreviewTypeMusic,
    };
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
