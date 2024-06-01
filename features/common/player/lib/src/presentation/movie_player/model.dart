import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/player.dart';
import 'package:player/src/utils/video_controller.dart';

typedef TranslationsData
    = Map<VideoTranslationTypeData, List<VideoTranslationData>>;

abstract interface class IMoviePlayerModel
    implements ElementaryModel, Listenable {
  MovieData? get movie;

  EpisodeData? get episode;

  TranslationsData get translations;

  VideoTranslationData? get translation;

  VideoController get videoController;

  void initialize({
    required Object movieId,
    required Object episodeId,
  });

  void changeTranslation(VideoTranslationData value);

  void loadPreviousEpisode();

  void loadNextEpisode();
}

class MoviePlayerModel extends ElementaryModel
    with ChangeNotifier
    implements IMoviePlayerModel {
  MoviePlayerModel(
    ErrorHandler errorHandler, {
    required PlayerService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  @override
  final VideoController videoController = VideoController();

  @override
  MovieData? movie;

  @override
  EpisodeData? episode;

  @override
  TranslationsData translations = const {};

  final PlayerService _service;

  VideoTranslationData? _translation;

  VideoData? _video;

  late int _episodeIndex;

  bool _episodeWatched = false;

  bool _listeningVideoPlayer = false;

  @override
  VideoTranslationData? get translation => _translation;

  @override
  Future<void> initialize({
    required Object movieId,
    required Object episodeId,
  }) async {
    movie = await _service.getMovie(movieId);
    _episodeIndex = movie!.episodes.indexWhere(
      (episode) => episode.id == episodeId,
    );
    _loadEpisode(index: _episodeIndex);
  }

  @override
  void changeTranslation(VideoTranslationData value) {
    _translation = value;
    notifyListeners();
    _loadVideo();
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
  Future<void> dispose() async {
    super.dispose();
    await videoController.dispose();
  }

  Future<void> _loadEpisode({
    required int index,
  }) async {
    if (_listeningVideoPlayer) {
      videoController.removeListener(_onVideoPlayerChanged);
      _listeningVideoPlayer = false;
    }
    if (videoController.value.isInitialized) {
      videoController.pause();
    }
    _episodeWatched = false;
    _episodeIndex = index;
    episode = movie!.episodes[index];
    final List<VideoTranslationData> translationsList =
        await _service.getTranslations(episode!.id);
    translations = {
      for (final VideoTranslationTypeData type
          in VideoTranslationTypeData.values)
        type: translationsList
            .where((translation) => translation.type == type)
            .toList(growable: false),
    };
    changeTranslation(translations[VideoTranslationTypeData.raw]!.first);
    videoController.addListener(_onVideoPlayerChanged);
    _listeningVideoPlayer = true;
  }

  Future<void> _loadVideo() async {
    _video = await _service.getTranslationVideo(translation!.embedUri);
    videoController.initializeUri(_video!.sources.values.first.uri);
    await videoController.play();
  }

  void _onVideoPlayerChanged() {
    final double positionPercentage = videoController.value.position.inSeconds /
        videoController.value.duration.inSeconds;
    if (positionPercentage >= 0.85 && !_episodeWatched) {
      _episodeWatched = true;
      _service.postTranslationWatched(
        translation!.id,
        csrf: _video!.csrf,
      );
    }

    final bool shouldLoadNextEpisode = videoController.value.isCompleted &&
        _episodeIndex < movie!.episodes.length - 1;
    if (shouldLoadNextEpisode) {
      loadNextEpisode();
    }
  }
}
