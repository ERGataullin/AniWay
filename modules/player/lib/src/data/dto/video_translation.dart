/// {@macro player.domain.models.video_translation.VideoTranslationData}
class VideoTranslationDto {
  const VideoTranslationDto({
    required this.id,
    required this.title,
    required this.type,
    required this.language,
    required this.embedUrl,
  });

  /// {@macro player.domain.models.video_translation.VideoTranslationData.id}
  final Object id;

  /// {@macro player.domain.models.video_translation.VideoTranslationData.title}
  final String title;

  /// {@macro player.domain.models.video_translation.VideoTranslationData.type}
  final String type;

  // ignore: lines_longer_than_80_chars
  /// {@macro player.domain.models.video_translation.VideoTranslationData.language}
  final String language;

  // ignore: lines_longer_than_80_chars
  /// {@macro player.domain.models.video_translation.VideoTranslationData.embedUri}
  final String embedUrl;
}
