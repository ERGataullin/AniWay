import 'package:player/player.dart';

/// {@template player.domain.models.video_source.VideoSourceData}
/// Источник видео.
/// {@endtemplate}
class VideoSourceData {
  const VideoSourceData({
    required this.quality,
    required this.uri,
  });

  /// Создание источника видео из соответствующего [VideoSourceDto].
  factory VideoSourceData.fromDto(VideoSourceDto dto) => VideoSourceData(
        quality: dto.quality,
        uri: Uri.parse(dto.url),
      );

  /// {@template player.domain.models.video_source.VideoSourceData.quality}
  /// Качество: 1080, 720 и др.
  /// {@endtemplate}
  final String quality;

  /// {@template player.domain.models.video_source.VideoSourceData.uri}
  /// URL видео.
  /// {@endtemplate}
  final Uri uri;
}
