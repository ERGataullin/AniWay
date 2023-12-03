import 'package:player/src/data/dto/video_source.dart';

export 'package:player/src/data/dto/video_source.dart';

/// {@macro player.domain.models.video.VideoData}
class VideoDto {
  const VideoDto({
    required this.sources,
  });

  /// {@macro player.domain.models.video.VideoData.sources}
  final Map<String, VideoSourceDto> sources;
}
