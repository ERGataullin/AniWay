import 'package:app/core/core.dart';
import 'package:app/movies/domain/models/episode.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/movies.dart';
import 'package:app/movies/presentation/movie/model.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

MovieWM movieWMFactory(BuildContext context) => MovieWM(
      MovieModel(
        errorHandler: context.read<ErrorHandler>(),
        repository: context.read<MoviesRepository>(),
      ),
    );

abstract interface class IMovieWM implements IWidgetModel {
  ValueListenable<bool> get loading;

  ValueListenable<WatchStatus?> get watchStatus;

  ValueListenable<ImageData?> get poster;

  ValueListenable<double?> get score;

  ValueListenable<String> get title;

  ValueListenable<List<String>> get genres;

  ValueListenable<String?> get description;

  ValueListenable<Uri?> get episodesUri;

  ValueListenable<int?> get episodesCount;

  ValueListenable<List<EpisodeData>> get episodes;

  void handlePlayPressed();

  void handleEpisodePressed(int episodeId);
}

class MovieWM extends WidgetModel<MovieWidget, IMovieModel>
    with ThemeWMMixin
    implements IMovieWM {
  MovieWM(super._model);

  @override
  late final Computed<WatchStatus?> watchStatus = Computed(
    trigger: model.watchStatusDetails,
    () => model.watchStatusDetails.value?.status,
  );

  @override
  late final Computed<ImageData?> poster = Computed(
    trigger: model.movie,
    () => model.movie.value?.poster,
  );

  @override
  late final Computed<double?> score = Computed(
    trigger: model.movie,
    () => model.movie.value?.score,
  );

  @override
  late final Computed<String> title = Computed(
    trigger: model.movie,
    () => model.movie.value?.title ?? '',
  );

  @override
  late final Computed<List<String>> genres = Computed(
    trigger: model.movie,
    () => model.movie.value?.genres ?? const [],
  );

  @override
  late final Computed<String?> description = Computed(
    trigger: model.movie,
    () => model.movie.value?.description,
  );

  @override
  late final Computed<Uri?> episodesUri = Computed(
    trigger: model.movie,
    () => switch (model.movie.value) {
      final MovieDetailsData movie when movie.episodes.length > 1 =>
        widget.episodesUri,
      _ => null,
    },
  );

  @override
  late final Computed<int?> episodesCount = Computed(
    trigger: model.movie,
    () => model.movie.value?.episodesCount,
  );

  @override
  late final Computed<List<EpisodeData>> episodes = Computed(
    trigger: model.movie,
    () => model.movie.value?.episodes ?? const [],
  );

  @override
  ValueListenable<bool> get loading => model.loading;

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
  void handlePlayPressed() {
    widget.onPlayPressed(model.nextEpisodeId.value);
  }

  @override
  void handleEpisodePressed(int episodeId) {
    widget.onEpisodePressed(episodeId);
  }

  @override
  void dispose() {
    watchStatus.dispose();
    poster.dispose();
    score.dispose();
    title.dispose();
    genres.dispose();
    description.dispose();
    episodesUri.dispose();
    episodesCount.dispose();
    episodes.dispose();
    super.dispose();
  }
}
