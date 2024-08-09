import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/presentation/movie/model.dart';


MovieWM movieWMFactory(BuildContext context) =>
    MovieWM(
      MovieModel(
        errorHandler: context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
      ),
      posterBaseUri: context
          .read<Network>()
          .baseUri,
    );

abstract interface class IMovieWM implements IWidgetModel {
  ValueListenable<bool> get showLoader;

  ValueListenable<ImageProvider?> get poster;

  ValueListenable<String> get playButtonLabel;

  VoidCallback? onPlayPressed();

  ValueListenable<String> get score;

  ValueListenable<String> get title;

  ValueListenable<String> get description;

  ValueListenable<String> get detailsFABLabel;
}

class MovieWM extends WidgetModel<MovieWidget, IMovieModel>
    with L10nWMMixin
    implements IMovieWM {
  MovieWM(super._model, {
    required Uri posterBaseUri,
  }) : _posterBaseUri = posterBaseUri;

  final Uri _posterBaseUri;

  final NumberFormat _scoreFormat = NumberFormat('#0.0');

  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  late final DynamicData<ImageProvider?> poster = DynamicData(
    trigger: model.movie,
        () =>
    model.movie.value == null
        ? null
        : NetworkImage(
      _posterBaseUri.resolveUri(model.movie.value!.posterUri).toString(),
    ),
  );

  @override
  late final DynamicData<String> playButtonLabel = DynamicData(
    trigger: l10n,
        () => l10n.value.playButtonLabel,
  );

  @override
  VoidCallback? onPlayPressed() {
    if(model.movie.value == null) widget.onPlayPressed(model.movie.value!.id);
  }

@override
late final DynamicData<String> score = DynamicData(
  trigger: model.movie,
      () => _scoreFormat.format(model.movie.value?.score),
);

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
late final DynamicData<String> detailsFABLabel = DynamicData(
  trigger: l10n,
      () => l10n.value.detailsFABLabel,
);

@override
void initWidgetModel() {
  super.initWidgetModel();
  model.loadData(
    movieId: widget.movieId,
  );
}

@override
void dispose() {
  super.dispose();
  poster.dispose();
  playButtonLabel.dispose();
  score.dispose();
  title.dispose();
  description.dispose();
}}
