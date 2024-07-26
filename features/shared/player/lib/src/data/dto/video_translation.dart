class VideoTranslationDto {
  const VideoTranslationDto({
    required this.id,
    required this.author,
    required this.type,
    required this.language,
  });

  final int id;

  final String author;

  final String type;

  final String language;
}
