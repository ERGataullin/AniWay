import 'package:player/player.dart';

enum VideoLanguage {
  en,
  ja,
  ru;
}

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
    required this.language,
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
        language: switch (dto.language) {
          'en' => VideoLanguage.en,
          'ja' => VideoLanguage.ja,
          'ru' => VideoLanguage.ru,
          _ => throw UnsupportedError(
              'Unsupported video translation type: ${dto.language}',
            ),
        },
      );

  final int id;

  final String title;

  final VideoTranslationType type;

  final VideoLanguage language;
}
