import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/components/video_player/typedefs.dart';

abstract interface class IVideoPlayerModel implements ElementaryModel {
  ValueListenable<VideoTranslationData?> get translation;

  ValueListenable<VideoData?> get video;

  ValueListenable<Uri?> get videoDataSource;

  set videoResolver(VideoResolver value);

  set translations(List<VideoTranslationData> value);

  double getMaxScale({
    required double surfaceAspectRatio,
    required double videoAspectRatio,
  });

  List<VideoTranslationData> getTranslations({
    required VideoTranslationTypeData type,
  });

  void switchTranslation(VideoTranslationData translation);
}

class VideoPlayerModel extends ElementaryModel implements IVideoPlayerModel {
  VideoPlayerModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);

  @override
  final ValueNotifier<VideoTranslationData?> translation = ValueNotifier(null);

  @override
  final ValueNotifier<VideoData?> video = ValueNotifier(null);

  @override
  late final ComputationNotifier<Uri?> videoDataSource = ComputationNotifier(
    trigger: video,
    computation: () => video.value?.stream.values.first,
  );

  late VideoResolver _videoResolver;

  late List<VideoTranslationData> _translations;

  @override
  set videoResolver(VideoResolver value) => _videoResolver = value;

  @override
  set translations(List<VideoTranslationData> value) {
    _translations = value;
    if (value.isEmpty) {
      video.value = null;
      return;
    }

    translation.value = value.first;
  }

  @override
  void init() {
    translation.addListener(_onTranslationChanged);
  }

  @override
  double getMaxScale({
    required double surfaceAspectRatio,
    required double videoAspectRatio,
  }) {
    return math.max(
      surfaceAspectRatio / videoAspectRatio,
      videoAspectRatio / surfaceAspectRatio,
    );
  }

  @override
  void switchTranslation(VideoTranslationData translation) {
    this.translation.value = translation;
  }

  @override
  List<VideoTranslationData> getTranslations({
    required VideoTranslationTypeData type,
  }) {
    return _translations
        .where((translation) => type == translation.type)
        .toList(growable: false);
  }

  @override
  void dispose() {
    translation.dispose();
    video.dispose();
    videoDataSource.dispose();
    super.dispose();
  }

  Future<void> _onTranslationChanged() async {
    video.value = null;
    if (translation.value != null)
      video.value = await _videoResolver(translation.value!.id);
  }
}
