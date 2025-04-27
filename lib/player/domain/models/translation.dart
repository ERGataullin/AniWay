import 'dart:ui';

import 'package:app/player/player.dart';

class TranslationData {
  const TranslationData({
    required this.id,
    required this.uri,
    required this.title,
    required this.type,
    required this.locale,
    required this.qualityType,
    this.authors = const [],
  });

  final int id;

  final Uri uri;

  final String title;

  final TranslationType type;

  final Locale locale;

  final QualityType qualityType;

  final List<TranslationAuthorData> authors;
}
