import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/domain/models/movie_player.dart';
import 'package:player/player.dart';

abstract interface class IMoviePlayerModel implements ElementaryModel {
  ValueListenable<MoviePlayerData?> get movie;

  ValueListenable<EpisodeData?> get episode;

  ValueListenable<List<VideoTranslationData>> get translations;

  void loadData({
    required Object movieId,
    required Object episodeId,
  });

  void loadPreviousEpisode();

  void loadNextEpisode();

  Future<VideoData> getVideo(Object translationId);

  void saveTranslationWatched(Object translationId);
}

class MoviePlayerModel extends ElementaryModel implements IMoviePlayerModel {
  MoviePlayerModel(
    ErrorHandler errorHandler, {
    required MoviesService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  @override
  final ValueNotifier<MoviePlayerData?> movie = ValueNotifier(null);

  @override
  final ValueNotifier<EpisodeData?> episode = ValueNotifier(null);

  @override
  final ValueNotifier<List<VideoTranslationData>> translations =
      ValueNotifier(const []);

  final MoviesService _service;

  late int _episodeIndex;

  @override
  Future<void> loadData({
    required Object movieId,
    required Object episodeId,
  }) async {
    movie.value = await _service.getPlayerMovie(movieId);
    _episodeIndex = movie.value!.episodes.indexWhere(
      (episode) => episode.id == episodeId,
    );
    _loadEpisode(index: _episodeIndex);
  }

  @override
  Future<void> loadPreviousEpisode() async {
    await _loadEpisode(index: _episodeIndex - 1);
  }

  @override
  Future<void> loadNextEpisode() async {
    await _loadEpisode(index: _episodeIndex + 1);
  }

  @override
  Future<VideoData> getVideo(Object translationId) {
    return _service.getTranslationVideo(translationId);
  }

  @override
  void saveTranslationWatched(Object translationId) {
    _service.saveTranslationWatched(translationId);
  }

  Future<void> _loadEpisode({
    required int index,
  }) async {
    translations.value = const [];
    _episodeIndex = index;
    episode.value = movie.value!.episodes[index];
    translations.value = await _service.getTranslations(episode.value!.id);
  }
}

// typedef TranslationsData
//     = Map<VideoTranslationTypeData, List<VideoTranslationData>>;

// abstract interface class IMoviePlayerModel implements ElementaryModel {
//   ValueListenable<MoviePlayerData?> get movie;

//   ValueListenable<EpisodeData?> get episode;

//   ValueListenable<TranslationsData> get translations;

//   ValueListenable<VideoTranslationData?> get translation;

//   ValueListenable<VideoData?> get video;

//   void initialize({
//     required Object movieId,
//     required Object episodeId,
//   });

//   void changeTranslation(VideoTranslationData value);

//   void loadPreviousEpisode();

//   void loadNextEpisode();
// }

// class MoviePlayerModel extends ElementaryModel implements IMoviePlayerModel {
//   MoviePlayerModel(
//     ErrorHandler errorHandler, {
//     required MoviesService service,
//   })  : _service = service,
//         super(errorHandler: errorHandler);

//   @override
//   final ValueNotifier<MoviePlayerData?> movie = ValueNotifier(null);

//   @override
//   final ValueNotifier<EpisodeData?> episode = ValueNotifier(null);

//   @override
//   final ValueNotifier<TranslationsData> translations = ValueNotifier(const {});

//   @override
//   final ValueNotifier<VideoTranslationData?> translation = ValueNotifier(null);

//   @override
//   final ValueNotifier<VideoData?> video = ValueNotifier(null);

//   final MoviesService _service;

//   late int _episodeIndex;

//   bool _episodeWatched = false;

//   bool _listeningVideoPlayer = false;

//   @override
//   Future<void> initialize({
//     required Object movieId,
//     required Object episodeId,
//   }) async {
//     movie.value = await _service.getPlayerMovie(movieId);
//     _episodeIndex = movie.value!.episodes.indexWhere(
//       (episode) => episode.id == episodeId,
//     );
//     _loadEpisode(index: _episodeIndex);
//   }

//   @override
//   void changeTranslation(VideoTranslationData value) {
//     translation.value = value;
//     _loadVideo();
//   }

//   @override
//   Future<void> loadPreviousEpisode() async {
//     await _loadEpisode(index: _episodeIndex - 1);
//   }

//   @override
//   Future<void> loadNextEpisode() async {
//     await _loadEpisode(index: _episodeIndex + 1);
//   }

//   @override
//   Future<void> dispose() async {
//     movie.dispose();
//     episode.dispose();
//     translations.dispose();
//     translation.dispose();
//     video.dispose();
//     super.dispose();
//   }

//   Future<void> _loadEpisode({
//     required int index,
//   }) async {
//     if (_listeningVideoPlayer) {
//       videoController.removeListener(_onVideoPlayerChanged);
//       _listeningVideoPlayer = false;
//     }
//     if (videoController.value.isInitialized) {
//       videoController.pause();
//     }
//     _episodeWatched = false;
//     _episodeIndex = index;
//     episode = movie.episodes[index];
//     final List<VideoTranslationData> translationsList =
//         await _service.getTranslations(episode.id);
//     translations = {
//       for (final VideoTranslationTypeData type
//           in VideoTranslationTypeData.values)
//         type: translationsList
//             .where((translation) => translation.type == type)
//             .toList(growable: false),
//     };
//     changeTranslation(translations[VideoTranslationTypeData.raw]!.first);
//     videoController.addListener(_onVideoPlayerChanged);
//     _listeningVideoPlayer = true;
//   }

//   Future<void> _loadVideo() async {
//     _video = await _service.getTranslationVideo(translation.embedUri);
//     videoController.initializeUri(_video!.sources.values.first.uri);
//     await videoController.play();
//   }

//   void _onVideoPlayerChanged() {
//     final double positionPercentage = videoController.value.position.inSeconds /
//         videoController.value.duration.inSeconds;
//     if (positionPercentage >= 0.85 && !_episodeWatched) {
//       _episodeWatched = true;
//       _service.postTranslationWatched(
//         translation.id,
//         csrf: _video!.csrf,
//       );
//     }

//     final bool shouldLoadNextEpisode = videoController.value.isCompleted &&
//         _episodeIndex < movie.episodes.length - 1;
//     if (shouldLoadNextEpisode) {
//       loadNextEpisode();
//     }
//   }
// }
