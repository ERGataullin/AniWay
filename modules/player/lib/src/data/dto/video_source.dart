/// {@macro player.domain.models.video_source.VideoSourceData}
class VideoSourceDto {
  const VideoSourceDto({
    required this.quality,
    required this.url,
  });

  /// {@macro player.domain.models.video_source.VideoSourceData.quality}
  final String quality;

  /// {@macro player.domain.models.video_source.VideoSourceData.url}
  final String url;
}
