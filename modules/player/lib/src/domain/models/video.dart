import 'package:player/player.dart';

export 'package:player/src/domain/models/video_source.dart';

class VideoData {
  const VideoData({
    required this.sources,
  });

  factory VideoData.fromDto(VideoDto dto) => VideoData(
        sources: dto.sources.map(
          (key, value) => MapEntry(
            key,
            VideoSourceData.fromDto(value),
          ),
        ),
      );

  final Map<String, VideoSourceData> sources;
}
