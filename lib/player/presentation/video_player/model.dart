import 'dart:math' as math;
import 'dart:ui';

import 'package:app/core/core.dart';
import 'package:app/player/player.dart';
import 'package:app/player/presentation/video_player/typedefs.dart';
import 'package:flutter/foundation.dart';

typedef TypedTranslations = Map<TranslationType, List<TranslationData>>;

typedef LocaledTranslations = Map<Locale, TypedTranslations>;

abstract interface class IVideoPlayerModel implements ElementaryModel {
  ValueListenable<LocaledTranslations> get translations;

  ValueListenable<TranslationData?> get translation;

  ValueListenable<VideoData?> get video;

  ValueListenable<num?> get quality;

  ValueListenable<Uri?> get videoDataSource;

  set videoResolver(VideoResolver value);

  set currentLocale(Locale value);

  double getMaxScale({
    required double surfaceAspectRatio,
    required double videoAspectRatio,
  });

  void setTranslations(List<TranslationData> value);

  void setTranslation(TranslationData translation);

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
  final ValueNotifier<TranslationData?> translation = ValueNotifier(null);

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

  TranslationData? _lastSelectedTranslation;

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
  void setTranslations(List<TranslationData> value) {
    translations.value = <Locale, TypedTranslations>{};
    for (final TranslationData translation in value) {
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
  void setTranslation(TranslationData translation) {
    this.translation.value = translation;
  }

  @override
  void setQuality(num quality) {
    _autoSelectQuality = false;
    this.quality.value = quality;
  }

  @override
  Future<void> handleVideoWatched() async {
    final Map<TranslationType, int> typesRates =
        await _repository.getTranslationTypesRates();
    final TranslationType type = translation.value!.type;
    _repository.saveTranslationTypesRates({
      ...typesRates,
      type: 1 + (typesRates[type] ?? 0),
    });

    final Map<String, int> authorsRates =
        await _repository.getTranslationAuthorsRates();
    _repository.saveTranslationAuthorsRates({
      ...authorsRates,
      for (final TranslationAuthorData author in translation.value!.authors)
        author.id: 1 + (authorsRates[author.id] ?? 0),
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
    video.value = null;
    if (translation.value != null) {
      _lastSelectedTranslation = translation.value;
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
    final TranslationType preferredType = await _getPreferredTranslationType(
      preferredLocale,
    );
    translation.value = await _getPreferredTranslation(
      locale: preferredLocale,
      type: preferredType,
    );
  }

  Locale _getPreferredLocale() {
    if (translations.value[_lastSelectedTranslation?.locale] != null) {
      return _lastSelectedTranslation!.locale;
    } else if (translations.value[_currentLocale] != null) {
      return _currentLocale!;
    } else {
      return translations.value.keys.first;
    }
  }

  Future<TranslationType> _getPreferredTranslationType(Locale locale) async {
    final Map<TranslationType, int> rates =
        await _repository.getTranslationTypesRates();

    TranslationType selectedType = TranslationType.raw;
    var selectedTypeRate = -1;
    for (final TranslationType type in translations.value[locale]!.keys) {
      final int rate = rates[type] ?? 0;
      if (selectedTypeRate > rate) continue;
      selectedType = type;
      selectedTypeRate = rate;
    }

    return selectedType;
  }

  Future<TranslationData> _getPreferredTranslation({
    required Locale locale,
    required TranslationType type,
  }) async {
    final List<TranslationData> preferredTranslations =
        translations.value[locale]![type]!;

    final List<TranslationAuthorData> lastSelectedAuthors =
        _lastSelectedTranslation?.authors ?? const [];
    final Map<String, int> authorsRates = {
      ...await _repository.getTranslationAuthorsRates(),
      for (final TranslationAuthorData author in lastSelectedAuthors)
        author.id: double.maxFinite.toInt() ~/ lastSelectedAuthors.length,
    };

    TranslationData preferredTranslation = preferredTranslations.first;
    double preferredRate = 0;
    for (final translation in preferredTranslations) {
      var authorsRateSum = 0;
      for (final TranslationAuthorData author in translation.authors) {
        authorsRateSum += authorsRates[author.id] ?? 0;
      }
      final double rate = authorsRateSum / translation.authors.length;
      if (rate <= preferredRate) continue;
      preferredTranslation = translation;
      preferredRate = rate;
    }

    return preferredTranslation;
  }
}
