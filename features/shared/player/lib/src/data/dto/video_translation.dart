class VideoTranslationDto {
  const VideoTranslationDto({
    required this.id,
    required this.title,
    required this.type,
    required this.language,
    this.authors = const [],
  });

  final int id;

  final String title;

  final String type;

  final String language;

  final List<String> authors;
}
