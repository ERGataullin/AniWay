import 'dart:ui';

import 'package:player/player.dart';

enum VideoTranslationTypeData {
  raw,

  sub,

  voice;
}

class VideoTranslationData {
  const VideoTranslationData({
    required this.id,
    required this.title,
    required this.type,
    required this.language,
    required this.embedUri,
  });

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

  final Object id;

  final String title;

  final VideoTranslationTypeData type;

  final Locale language;

  final Uri embedUri;
}
