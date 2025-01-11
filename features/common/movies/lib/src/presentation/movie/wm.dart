import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/domain/models/movie_details.dart';
import 'package:movies/src/domain/models/watch_status.dart';
import 'package:movies/src/presentation/movie/model.dart';
import 'package:theme/theme.dart';

MovieWM movieWMFactory(BuildContext context) => MovieWM(
      MovieModel(
        errorHandler: context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class IMovieWM implements IWidgetModel {
  ValueListenable<bool> get showLoader;

  ValueListenable<bool> get showPlayButton;

  ValueListenable<bool> get watchStatusSelected;

  ValueListenable<String> get watchStatusTooltip;

  ValueListenable<ImageData?> get poster;

  ValueListenable<double?> get posterHeight;

  ValueListenable<String> get playButtonLabel;

  ValueListenable<double?> get score;

  ValueListenable<String> get title;

  ValueListenable<String> get genres;

  ValueListenable<String?> get description;

  ValueListenable<bool> get showEpisodes;

  ValueListenable<Uri?> get episodesUri;

  ValueListenable<String> get episodesLabel;

  ValueListenable<String> get episodesCount;

  ValueListenable<List<EpisodeData>> get episodes;

  String getEpisodeTitle(EpisodeData episode);

  void handlePlayPressed();

  void handleEpisodePressed(int episodeId);
}

class MovieWM extends WidgetModel<MovieWidget, IMovieModel>
    with L10nWMMixin, ThemeWMMixin
    implements IMovieWM {
  MovieWM(super._model);

  @override
  late final Computed<bool> watchStatusSelected = Computed(
    trigger: model.watchStatusDetails,
    () => switch (model.watchStatusDetails.value?.status) {
      null || WatchStatus.none => false,
      _ => true,
    },
  );

  @override
  late final Computed<String> watchStatusTooltip = Computed(
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
  late final Computed<ImageData?> poster = Computed(
    trigger: model.movie,
    () => model.movie.value?.poster,
  );

  @override
  late final Computed<double?> posterHeight = Computed(
    trigger: showLoader,
    () => showLoader.value ? null : MediaQuery.of(context).size.width * 1.25,
  );

  @override
  late final Computed<bool> showPlayButton = Computed(
    trigger: model.movie,
    () => model.movie.value?.episodes.isNotEmpty ?? false,
  );

  @override
  late final Computed<String> playButtonLabel = Computed(
    trigger: l10n,
    () => l10n.value.videoPlayLabel,
  );

  @override
  late final Computed<double?> score = Computed(
    trigger: model.movie,
    () => model.movie.value?.score,
  );

  @override
  late final Computed<String> title = Computed(
    trigger: Listenable.merge([showLoader, model.movie]),
    () => showLoader.value ? '' : model.movie.value?.title ?? '',
  );

  @override
  late final Computed<String> genres = Computed(
    trigger: model.movie,
    () => model.movie.value?.genres.join(' · ') ?? '',
  );

  @override
  late final Computed<String?> description = Computed(
    trigger: model.movie,
    () => model.movie.value?.description,
  );

  @override
  late final Computed<bool> showEpisodes = Computed(
    trigger: model.movie,
    () => model.movie.value?.episodes.isNotEmpty ?? false,
  );

  @override
  late final Computed<Uri?> episodesUri = Computed(
    trigger: model.movie,
    () => switch (model.movie.value) {
      final MovieDetailsData movie when movie.episodes.length > 24 =>
        widget.episodesUri,
      _ => null,
    },
  );

  @override
  late final Computed<String> episodesLabel = Computed(
    trigger: l10n,
    () => l10n.value.episodesLabel,
  );

  @override
  late final Computed<String> episodesCount = Computed(
    trigger: Listenable.merge([l10n, model.movie]),
    () => switch (model.movie.value) {
      final MovieDetailsData movie when movie.episodesCount != null =>
        l10n.value.xOfY(
          min(movie.episodes.length, movie.episodesCount!),
          movie.episodesCount!,
        ),
      final MovieDetailsData movie =>
        l10n.value.releasedCount(movie.episodes.length),
      null => '',
    },
  );

  @override
  late final Computed<List<EpisodeData>> episodes = Computed(
    trigger: model.movie,
    () => model.movie.value?.episodes ?? const [],
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
  void didUpdateWidget(MovieWidget oldWidget) {
    episodesUri.update();
    super.didUpdateWidget(oldWidget);
  }

  @override
  String getEpisodeTitle(EpisodeData episodeData) {
    return context.l10n.movieEpisode(
      episodeData.type.name,
      episodeData.number ?? 0,
    );
  }

  @override
  void handlePlayPressed() {
    widget.onPlayPressed(model.nextEpisodeId.value);
  }

  @override
  void handleEpisodePressed(int episodeId) {
    widget.onEpisodePressed(episodeId);
  }

  @override
  void didChangeDependencies() {
    posterHeight.update();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    watchStatusSelected.dispose();
    watchStatusTooltip.dispose();
    poster.dispose();
    posterHeight.dispose();
    showPlayButton.dispose();
    playButtonLabel.dispose();
    score.dispose();
    title.dispose();
    genres.dispose();
    description.dispose();
    showEpisodes.dispose();
    episodesUri.dispose();
    episodesLabel.dispose();
    episodesCount.dispose();
    episodes.dispose();
    super.dispose();
  }
}
