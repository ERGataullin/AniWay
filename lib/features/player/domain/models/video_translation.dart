import 'dart:ui';

import 'package:app/features/player/player.dart';

class VideoTranslationData {
  const VideoTranslationData({
    required this.id,
    required this.title,
    required this.type,
    required this.locale,
    required this.qualityType,
    this.authors = const [],
  });

  final int id;

  final String title;

  final VideoTranslationType type;

  final Locale locale;

  final VideoQualityType qualityType;

  final List<String> authors;
}
