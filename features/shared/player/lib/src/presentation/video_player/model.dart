import 'dart:math' as math;
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/video_player/typedefs.dart';

typedef LocaledTranslations = Map<Locale, List<VideoTranslationData>>;

abstract interface class IVideoPlayerModel implements ElementaryModel {
  ValueListenable<LocaledTranslations> get translations;

  ValueListenable<VideoTranslationData?> get translation;

  ValueListenable<VideoData?> get video;

  ValueListenable<Uri?> get videoDataSource;

  set videoResolver(VideoResolver value);

  double getMaxScale({
    required double surfaceAspectRatio,
    required double videoAspectRatio,
  });

  void setTranslations(List<VideoTranslationData> value);

  void switchTranslation(VideoTranslationData translation);
}

class VideoPlayerModel extends ElementaryModel implements IVideoPlayerModel {
  VideoPlayerModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);

  @override
  final ValueNotifier<LocaledTranslations> translations =
      ValueNotifier(const {});

  @override
  final ValueNotifier<VideoTranslationData?> translation = ValueNotifier(null);

  @override
  final ValueNotifier<VideoData?> video = ValueNotifier(null);

  @override
  late final DynamicData<Uri?> videoDataSource = DynamicData(
    trigger: video,
    () => video.value?.stream.values.first,
  );

  late VideoResolver _videoResolver;

  @override
  set videoResolver(VideoResolver value) => _videoResolver = value;

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
  void setTranslations(List<VideoTranslationData> value) {
    final LocaledTranslations translations = {};
    for (final VideoTranslationData translation in value) {
      if (translation.type == VideoTranslationType.sub) continue;
      translations[translation.locale] = [
        ...translations[translation.locale] ?? const [],
        translation,
      ];
    }
    this.translations.value = Map.unmodifiable(translations);
    if (value.isEmpty) {
      video.value = null;
      return;
    }

    translation.value = translations.values.first.first;
  }

  @override
  void switchTranslation(VideoTranslationData translation) {
    this.translation.value = translation;
  }

  @override
  void dispose() {
    translations.dispose();
    translation.dispose();
    video.dispose();
    videoDataSource.dispose();
    super.dispose();
  }

  Future<void> _onTranslationChanged() async {
    video.value = null;
    if (translation.value != null) {
      video.value = await _videoResolver(translation.value!.id);
    }
  }
}
