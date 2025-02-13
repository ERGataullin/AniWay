import 'dart:math' as math;
import 'dart:ui';

import 'package:app/core/core.dart';
import 'package:app/player/player.dart';
import 'package:app/player/presentation/video_player/typedefs.dart';
import 'package:flutter/foundation.dart';

typedef LocaledTranslations = Map<Locale, List<VideoTranslationData>>;

abstract interface class IVideoPlayerModel implements ElementaryModel {
  ValueListenable<LocaledTranslations> get translations;

  ValueListenable<VideoTranslationData?> get translation;

  ValueListenable<VideoData?> get video;

  ValueListenable<num?> get quality;

  ValueListenable<Uri?> get videoDataSource;

  set videoResolver(VideoResolver value);

  set locale(Locale value);

  double getMaxScale({
    required double surfaceAspectRatio,
    required double videoAspectRatio,
  });

  void setTranslations(List<VideoTranslationData> value);

  void setTranslation(VideoTranslationData translation);

  void setQuality(num quality);

  void handleVideoWatched();
}

class VideoPlayerModel extends ElementaryModel implements IVideoPlayerModel {
  VideoPlayerModel({
    super.errorHandler,
    required PlayerRepository repository,
  }) : _repository = repository;

  @override
  final ValueNotifier<LocaledTranslations> translations =
      ValueNotifier(const {});

  @override
  final ValueNotifier<VideoTranslationData?> translation = ValueNotifier(null);

  @override
  final ValueNotifier<VideoData?> video = ValueNotifier(null);

  @override
  final ValueNotifier<num?> quality = ValueNotifier(null);

  @override
  late final Computed<Uri?> videoDataSource = Computed(
    trigger: Listenable.merge([video, quality]),
    () => video.value?.stream[quality.value],
  );

  final PlayerRepository _repository;

  late VideoResolver _videoResolver;

  var _autoSelectQuality = true;

  Locale? _locale;

  Locale? _selectedTranslationLocale;

  List<String> _selectedTranslationAuthors = const [];

  @override
  set videoResolver(VideoResolver value) => _videoResolver = value;

  @override
  set locale(Locale value) => _locale = value;

  @override
  void init() {
    translation.addListener(_handleTranslationChanged);
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
    final translations = <Locale, List<VideoTranslationData>>{};
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
    _autoSelectTranslation();
  }

  @override
  void setTranslation(VideoTranslationData translation) {
    this.translation.value = translation;
  }

  @override
  void setQuality(num quality) {
    _autoSelectQuality = false;
    this.quality.value = quality;
  }

  @override
  Future<void> handleVideoWatched() async {
    final Map<String, int> authorsRates =
        await _repository.getPersonalizedTranslationAuthorsRates();
    _repository.savePersonalizedTranslationAuthorsRates({
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
    quality.dispose();
    videoDataSource.dispose();
    super.dispose();
  }

  Future<void> _handleTranslationChanged() async {
    _selectedTranslationLocale =
        translation.value?.locale ?? _selectedTranslationLocale;
    _selectedTranslationAuthors = translation.value?.authors
            .map((author) => author.toLowerCase())
            .toList(growable: false) ??
        _selectedTranslationAuthors;
    video.value = null;
    if (translation.value != null) {
      video.value = await _videoResolver(translation.value!.id);
      quality.value = _autoSelectQuality
          ? video.value!.stream.keys.first
          : video.value!.stream.containsKey(quality.value)
              ? quality.value
              : video.value!.stream.keys.first;
    }
  }

  Future<void> _autoSelectTranslation() async {
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
      ...await _repository.getPersonalizedTranslationAuthorsRates(),
      for (final String author in _selectedTranslationAuthors)
        author: double.maxFinite.toInt(),
    };
    VideoTranslationData suitableTranslation = suitableLocaleTranslations.first;
    double suitability = 0;
    for (final translation in suitableLocaleTranslations) {
      var translationSuitabilitySum = 0;
      for (final String author in translation.authors) {
        translationSuitabilitySum +=
            authorsSuitability[author.trim().toLowerCase()] ?? 0;
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
