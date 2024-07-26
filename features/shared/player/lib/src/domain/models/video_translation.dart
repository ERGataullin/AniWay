import 'dart:ui';

import 'package:player/player.dart';
import 'package:player/src/domain/models/video_translation_type.dart';

class VideoTranslationData {
  const VideoTranslationData({
    required this.id,
    required this.title,
    required this.type,
    required this.locale,
    this.authors = const [],
  });

  factory VideoTranslationData.fromDto(VideoTranslationDto dto) =>
      VideoTranslationData(
        id: dto.id,
        title: dto.title,
        type: VideoTranslationType.valueOf(dto.type),
        locale: Locale.fromSubtags(languageCode: dto.language),
        authors: dto.authors,
      );

  final int id;

  final String title;

  final VideoTranslationType type;

  final Locale locale;

  final List<String> authors;
}
