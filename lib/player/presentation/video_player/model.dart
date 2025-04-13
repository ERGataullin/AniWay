import 'dart:math' as math;
import 'dart:ui';

import 'package:app/core/core.dart';
import 'package:app/player/player.dart';
import 'package:app/player/presentation/video_player/typedefs.dart';
import 'package:flutter/foundation.dart';

typedef TypedTranslations =
    Map<VideoTranslationType, List<VideoTranslationData>>;

typedef LocaledTranslations = Map<Locale, TypedTranslations>;

abstract interface class IVideoPlayerModel implements ElementaryModel {
  ValueListenable<LocaledTranslations> get translations;

  ValueListenable<VideoTranslationData?> get translation;

  ValueListenable<VideoData?> get video;

  ValueListenable<num?> get quality;

  ValueListenable<Uri?> get videoDataSource;

  set videoResolver(VideoResolver value);

  set currentLocale(Locale value);

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
  VideoPlayerModel({super.errorHandler, required PlayerRepository repository})
    : _repository = repository;

  @override
  final ValueNotifier<LocaledTranslations> translations = ValueNotifier(
    const {},
  );

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

  Locale? _currentLocale;
  @override
  set currentLocale(Locale value) => _currentLocale = value;

  Locale? _selectedTranslationLocale;

  List<String> _selectedTranslationAuthors = const [];

  @override
  set videoResolver(VideoResolver value) => _videoResolver = value;

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
    translations.value = <Locale, TypedTranslations>{};
    for (final VideoTranslationData translation in value) {
      // Получение "словаря" уже добавленных переводов такой же локализации,
      // или создание такового при его отсутствии.
      // Словарь разбит по типу перевода.
      final TypedTranslations sameLocaleTypedTranslations = translations.value
          .putIfAbsent(translation.locale, () => {});

      // Получение списка уже добавленных переводов такой же локализации и
      // типа перевода, или создание такового при его отсутствии.
      sameLocaleTypedTranslations
          .putIfAbsent(translation.type, () => [])
          // Добавление перевода в список уже добавленных
          .add(translation);
    }

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
    final Map<VideoTranslationType, int> typesRates =
        await _repository.getTranslationTypesRates();
    final VideoTranslationType type = translation.value!.type;
    _repository.saveTranslationTypesRates({
      ...typesRates,
      type: 1 + (typesRates[type] ?? 0),
    });

    final Map<String, int> authorsRates =
        await _repository.getTranslationAuthorsRates();
    _repository.saveTranslationAuthorsRates({
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
    _selectedTranslationAuthors =
        translation.value?.authors
            .map((author) => author.toLowerCase())
            .toList(growable: false) ??
        _selectedTranslationAuthors;
    video.value = null;
    if (translation.value != null) {
      video.value = await _videoResolver(translation.value!.id);
      quality.value =
          _autoSelectQuality
              ? video.value!.stream.keys.first
              : video.value!.stream.containsKey(quality.value)
              ? quality.value
              : video.value!.stream.keys.first;
    }
  }

  Future<void> _autoSelectTranslation() async {
    final Locale preferredLocale = _getPreferredLocale();
    final VideoTranslationType preferredType = await _autoSelectTranslationType(
      preferredLocale,
    );
    translation.value = await _getPreferredTranslation(
      locale: preferredLocale,
      type: preferredType,
    );
  }

  Locale _getPreferredLocale() {
    if (translations.value[_selectedTranslationLocale] != null) {
      return _selectedTranslationLocale!;
    } else if (translations.value[_currentLocale] != null) {
      return _currentLocale!;
    } else {
      return translations.value.keys.first;
    }
  }

  Future<VideoTranslationType> _autoSelectTranslationType(Locale locale) async {
    final Map<VideoTranslationType, int> rates =
        await _repository.getTranslationTypesRates();

    VideoTranslationType selectedType = VideoTranslationType.raw;
    int selectedTypeRate = -1;
    for (final VideoTranslationType type in translations.value[locale]!.keys) {
      final int rate = rates[type] ?? 0;
      if (selectedTypeRate > rate) continue;
      selectedType = type;
      selectedTypeRate = rate;
    }

    return selectedType;
  }

  Future<VideoTranslationData> _getPreferredTranslation({
    required Locale locale,
    required VideoTranslationType type,
  }) async {
    final List<VideoTranslationData> preferredTranslations =
        translations.value[locale]![type]!;

    final Map<String, int> authorsSuitability = {
      ...await _repository.getTranslationAuthorsRates(),
      for (final String author in _selectedTranslationAuthors)
        author: double.maxFinite.toInt(),
    };
    VideoTranslationData preferredTranslation = preferredTranslations.first;
    double preferredRate = 0;
    for (final translation in preferredTranslations) {
      var authorsRate = 0;
      for (final String author in translation.authors) {
        authorsRate += authorsSuitability[author.trim().toLowerCase()] ?? 0;
      }
      final double rate = authorsRate / translation.authors.length;
      if (rate <= preferredRate) continue;
      preferredTranslation = translation;
      preferredRate = rate;
    }

    return preferredTranslation;
  }
}
