import 'package:player/player.dart';

export 'package:player/src/domain/models/video_source.dart';

/// {@template player.domain.models.video.VideoData}
/// Видео.
/// {@endtemplate}
class VideoData {
  const VideoData({
    required this.sources,
  });

  /// Создание видео из соответствующего [VideoDto].
  factory VideoData.fromDto(VideoDto dto) => VideoData(
        sources: dto.sources.map(
          (key, value) => MapEntry(
            key,
            VideoSourceData.fromDto(value),
          ),
        ),
      );

  /// {@template player.domain.models.video.VideoData.sources}
  /// Источники.
  ///
  /// Ключ - качество видео, значение - источник.
  /// {@endtemplate}
  final Map<String, VideoSourceData> sources;
}
