import 'package:player/src/data/dto/video_source.dart';

export 'package:player/src/data/dto/video_source.dart';

class VideoDto {
  const VideoDto({
    this.csrf,
    required this.sources,
  });

  final String? csrf;

  final Map<String, VideoSourceDto> sources;
}
