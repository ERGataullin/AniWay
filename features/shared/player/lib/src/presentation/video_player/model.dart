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

  set locale(Locale value);

  double getMaxScale({
    required double surfaceAspectRatio,
    required double videoAspectRatio,
  });

  void setTranslations(List<VideoTranslationData> value);

  void switchTranslation(VideoTranslationData translation);
}

class VideoPlayerModel extends ElementaryModel implements IVideoPlayerModel {
  VideoPlayerModel({super.errorHandler});

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

  Locale? _locale;

  Locale? _translationLocale;

  String? _translationAuthor;

  @override
  set videoResolver(VideoResolver value) => _videoResolver = value;

  @override
  set locale(Locale value) => _locale = value;

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
      translation.value = null;
      return;
    }
    List<VideoTranslationData>? translationsForLocale;
    if (_translationLocale != null) {
      translationsForLocale ??= this.translations.value[_translationLocale];
    }
    if (_locale != null) {
      translationsForLocale ??= this.translations.value[_locale];
    }
    translationsForLocale ??= this.translations.value.values.first;
    translation
      ..value = translationsForLocale
          .where((translation) => translation.author == _translationAuthor)
          .singleOrNull
      ..value ??= translationsForLocale.first;
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
    _translationLocale = translation.value?.locale ?? _translationLocale;
    _translationAuthor = translation.value?.author ?? _translationAuthor;
    video.value = null;
    if (translation.value != null) {
      video.value = await _videoResolver(translation.value!.id);
    }
  }
}
