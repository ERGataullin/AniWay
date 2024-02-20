import 'package:player/player.dart';

export 'package:player/src/domain/models/video_source.dart';

class VideoData {
  const VideoData({
    this.csrf,
    required this.sources,
  });

  factory VideoData.fromDto(VideoDto dto) => VideoData(
        csrf: dto.csrf,
        sources: dto.sources.map(
          (key, value) => MapEntry(
            key,
            VideoSourceData.fromDto(value),
          ),
        ),
      );

  final String? csrf;

  final Map<String, VideoSourceData> sources;
}
