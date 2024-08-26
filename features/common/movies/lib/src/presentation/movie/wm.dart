import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/domain/models/watch_status.dart';
import 'package:movies/src/presentation/movie/model.dart';

MovieWM movieWMFactory(BuildContext context) => MovieWM(
      MovieModel(
        errorHandler: context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
      ),
      posterBaseUri: context.read<Network>().baseUri,
    );

abstract interface class IMovieWM implements IWidgetModel {
  ValueListenable<bool> get showLoader;

  ValueListenable<bool> get watchStatusSelected;

  ValueListenable<String> get watchStatusButtonTooltip;

  ValueListenable<ImageProvider?> get poster;

  ValueListenable<String> get playButtonLabel;

  ValueListenable<double?> get score;

  ValueListenable<String> get title;

  ValueListenable<String> get description;

  ValueListenable<List<EpisodeData>> get episodes;

  ValueListenable<bool> get showEpisodes;

  void handlePlayPressed();
}

class MovieWM extends WidgetModel<MovieWidget, IMovieModel>
    with L10nWMMixin
    implements IMovieWM {
  MovieWM(
    super._model, {
    required Uri posterBaseUri,
  }) : _posterBaseUri = posterBaseUri;

  final Uri _posterBaseUri;

  @override
  late final DynamicData<bool> watchStatusSelected = DynamicData(
    trigger: model.watchStatusDetails,
    () => switch (model.watchStatusDetails.value?.status) {
      null || WatchStatus.none => false,
      _ => true,
    },
  );

  @override
  late final DynamicData<String> watchStatusButtonTooltip = DynamicData(
    trigger: Listenable.merge([
      l10n,
      model.watchStatusDetails,
    ]),
    () => switch (model.watchStatusDetails.value?.status) {
      null => '',
      WatchStatus.none => l10n.value.watchStatusAdd,
      final WatchStatus other => l10n.value.watchStatus(other.name),
    },
  );

  @override
  late final DynamicData<ImageProvider?> poster = DynamicData(
    trigger: model.movie,
    () => model.movie.value == null
        ? null
        : NetworkImage(
            _posterBaseUri.resolveUri(model.movie.value!.posterUri).toString(),
          ),
  );

  @override
  late final DynamicData<String> playButtonLabel = DynamicData(
    trigger: l10n,
    () => l10n.value.playLabel,
  );

  @override
  late final DynamicData<double?> score = DynamicData(
    trigger: model.movie,
    () => model.movie.value?.score,
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
  late final DynamicData<List<EpisodeData>> episodes = DynamicData(
    trigger: model.movie,
    () => model.movie.value?.episodes ?? const [],
  );

  @override
  late final DynamicData<bool> showEpisodes = DynamicData(
    trigger: model.movie,
    () =>
        model.movie.value?.episodes != null &&
        model.movie.value!.episodes.length > 1,
  );

  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model.loadData(
      movieId: widget.movieId,
    );
  }

  @override
  void handlePlayPressed() {
    widget.onPlayPressed(model.nextEpisodeId);
  }

  @override
  void dispose() {
    watchStatusSelected.dispose();
    watchStatusButtonTooltip.dispose();
    poster.dispose();
    playButtonLabel.dispose();
    score.dispose();
    title.dispose();
    description.dispose();
    episodes.dispose();
    showEpisodes.dispose();
    super.dispose();
  }
}
