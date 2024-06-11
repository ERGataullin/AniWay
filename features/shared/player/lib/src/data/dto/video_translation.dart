class VideoTranslationDto {
  const VideoTranslationDto({
    required this.id,
    required this.title,
    required this.type,
    required this.language,
  });

  final Object id;

  final String title;

  final String type;

  final String language;
}
