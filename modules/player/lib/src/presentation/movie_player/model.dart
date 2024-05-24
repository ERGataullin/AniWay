import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/player.dart';
import 'package:player/src/utils/video_controller.dart';

typedef TranslationsData
    = Map<VideoTranslationTypeData, List<VideoTranslationData>>;

abstract interface class IMoviePlayerModel
    implements ElementaryModel, Listenable {
  MovieData get movie;

  EpisodeData get episode;

  TranslationsData get translations;

  VideoTranslationData get translation;

  VideoController get videoController;

  set translation(VideoTranslationData value);

  void initialize({
    required Object movieId,
    required Object episodeId,
  });

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
  late MovieData movie;

  @override
  late EpisodeData episode;

  @override
  TranslationsData translations = const {};

  final PlayerService _service;

  late VideoTranslationData _translation;

  late VideoData _video;

  late int _episodeIndex;

  bool _episodeCompleted = false;

  @override
  VideoTranslationData get translation => _translation;

  @override
  set translation(VideoTranslationData value) {
    _translation = value;
    notifyListeners();
    _loadVideo();
  }

  @override
  Future<void> initialize({
    required Object movieId,
    required Object episodeId,
  }) async {
    videoController.addListener(_onVideoPlayerChanged);
    movie = await _service.getMovie(movieId);
    _episodeIndex = movie.episodes.indexWhere(
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
  Future<void> dispose() async {
    super.dispose();
    await videoController.dispose();
  }

  Future<void> _loadEpisode({
    required int index,
  }) async {
    _episodeIndex = index;
    episode = movie.episodes[index];
    final List<VideoTranslationData> translationsList =
        await _service.getTranslations(episode.id);
    translations = {
      for (final VideoTranslationTypeData type
          in VideoTranslationTypeData.values)
        type: translationsList
            .where((translation) => translation.type == type)
            .toList(growable: false),
    };
    translation = translations[VideoTranslationTypeData.raw]!.first;
  }

  Future<void> _loadVideo() async {
    _video = await _service.getTranslationVideo(translation.embedUri);
    videoController.initializeUri(_video.sources.values.first.uri);
    await videoController.play();
  }

  void _onVideoPlayerChanged() {
    if (_episodeCompleted) {
      _episodeCompleted = videoController.value.isCompleted;
      return;
    } else if (!videoController.value.isCompleted) {
      return;
    }

    _episodeCompleted = true;
    if (_episodeIndex < movie.episodes.length - 1) {
      loadNextEpisode();
    }
    _service.postTranslationWatched(
      translation.id,
      csrf: _video.csrf,
    );
  }
}
