import 'dart:ui';

import 'package:player/player.dart';

/// {@template player.domain.models.video_translation.VideoTranslationTypeData}
/// Тип перевода видео.
/// {@endtemplate}
enum VideoTranslationTypeData {
  /// Оригинал.
  raw,

  /// Субтитры.
  sub,

  /// Озвучка.
  voice;
}

/// {@template player.domain.models.video_translation.VideoTranslationData}
/// Перевод видео.
/// {@endtemplate}
class VideoTranslationData {
  const VideoTranslationData({
    required this.id,
    required this.title,
    required this.type,
    required this.language,
    required this.embedUri,
  });

  /// Создание перевода видео из соответствующего [VideoTranslationDto].
  factory VideoTranslationData.fromDto(VideoTranslationDto dto) =>
      VideoTranslationData(
        id: dto.id,
        title: dto.title,
        type: switch (dto.type) {
          'raw' => VideoTranslationTypeData.raw,
          'sub' => VideoTranslationTypeData.sub,
          'voice' => VideoTranslationTypeData.voice,
          _ => throw UnsupportedError(
              'Unsupported video translation type: ${dto.type}',
            ),
        },
        language: Locale.fromSubtags(languageCode: dto.language),
        embedUri: Uri.parse(dto.embedUrl),
      );

  /// {@template player.domain.models.video_translation.VideoTranslationData.id}
  /// Идентификатор.
  /// {@endtemplate}
  final Object id;

  // ignore: lines_longer_than_80_chars
  /// {@template player.domain.models.video_translation.VideoTranslationData.title}
  /// Название.
  /// {@endtemplate}
  final String title;

  // ignore: lines_longer_than_80_chars
  /// {@template player.domain.models.video_translation.VideoTranslationData.type}
  /// Тип: оригинал, субтитры, озвучка.
  /// {@endtemplate}
  final VideoTranslationTypeData type;

  // ignore: lines_longer_than_80_chars
  /// {@template player.domain.models.video_translation.VideoTranslationData.language}
  /// Язык.
  /// {@endtemplate}
  final Locale language;

  // ignore: lines_longer_than_80_chars
  /// {@template player.domain.models.video_translation.VideoTranslationData.embedUri}
  /// URL HTML для встраивания видео.
  /// {@endtemplate}
  final Uri embedUri;
}
