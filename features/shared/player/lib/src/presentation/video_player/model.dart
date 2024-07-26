import 'dart:math' as math;
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/player.dart';
import 'package:player/src/domain/models/video_translation_type.dart';
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

  void handleVideoWatched();
}

class VideoPlayerModel extends ElementaryModel implements IVideoPlayerModel {
  VideoPlayerModel({
    super.errorHandler,
    required PlayerService service,
  }) : _service = service;

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

  final PlayerService _service;

  late VideoResolver _videoResolver;

  Locale? _locale;

  Locale? _selectedTranslationLocale;

  List<String> _selectedTranslationAuthors = const [];

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
    _autoselectTranslation();
  }

  @override
  void switchTranslation(VideoTranslationData translation) {
    this.translation.value = translation;
  }

  @override
  Future<void> handleVideoWatched() async {
    final Map<String, int> authorsRates =
        await _service.getPersonalizedTranslationAuthorsRates();
    _service.savePersonalizedTranslationAuthorsRates({
      ...authorsRates,
      for (final String author in _selectedTranslationAuthors)
        author: 1 + (authorsRates[author] ?? 0),
    });
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
    _selectedTranslationLocale =
        translation.value?.locale ?? _selectedTranslationLocale;
    _selectedTranslationAuthors =
        translation.value?.authors ?? _selectedTranslationAuthors;
    video.value = null;
    if (translation.value != null) {
      video.value = await _videoResolver(translation.value!.id);
    }
  }

  Future<void> _autoselectTranslation() async {
    late final Locale suitableLocale;
    if (translations.value[_selectedTranslationLocale] != null) {
      suitableLocale = _selectedTranslationLocale!;
    } else if (translations.value[_locale] != null) {
      suitableLocale = _locale!;
    } else {
      suitableLocale = translations.value.keys.first;
    }
    final List<VideoTranslationData> suitableLocaleTranslations =
        translations.value[suitableLocale]!;

    final Map<String, int> authorsSuitability = {
      ...await _service.getPersonalizedTranslationAuthorsRates(),
      for (final String author in _selectedTranslationAuthors)
        author: double.maxFinite.toInt(),
    };
    VideoTranslationData suitableTranslation = suitableLocaleTranslations.first;
    double suitability = 0;
    for (final VideoTranslationData translation in suitableLocaleTranslations) {
      int translationSuitabilitySum = 0;
      for (final String author in translation.authors) {
        translationSuitabilitySum += authorsSuitability[author] ?? 0;
      }
      final double translationSuitability =
          translationSuitabilitySum / translation.authors.length;
      if (translationSuitability <= suitability) continue;
      suitableTranslation = translation;
      suitability = translationSuitability;
    }
    translation.value = suitableTranslation;
  }
}
