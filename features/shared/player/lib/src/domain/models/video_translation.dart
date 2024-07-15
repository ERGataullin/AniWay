import 'dart:ui';

import 'package:player/player.dart';

enum VideoTranslationType {
  raw,
  sub,
  voice;
}

class VideoTranslationData {
  const VideoTranslationData({
    required this.id,
    required this.title,
    required this.type,
    required this.locale,
  });

  factory VideoTranslationData.fromDto(VideoTranslationDto dto) =>
      VideoTranslationData(
        id: dto.id,
        title: dto.title,
        type: switch (dto.type) {
          'raw' => VideoTranslationType.raw,
          'sub' => VideoTranslationType.sub,
          'voice' => VideoTranslationType.voice,
          _ => throw UnsupportedError(
              'Unsupported video translation type: ${dto.type}',
            ),
        },
        locale: Locale.fromSubtags(languageCode: dto.language),
      );

  final int id;

  final String title;

  final VideoTranslationType type;

  final Locale locale;
}
