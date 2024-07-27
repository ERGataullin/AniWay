class VideoTranslationDto {
  const VideoTranslationDto({
    required this.id,
    required this.title,
    required this.type,
    required this.language,
    required this.qualityType,
    this.authors = const [],
  });

  final int id;

  final String title;

  final String type;

  final String language;

  final String qualityType;

  final List<String> authors;
}
