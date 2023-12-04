import 'package:player/src/data/dto/video_source.dart';

export 'package:player/src/data/dto/video_source.dart';

class VideoDto {
  const VideoDto({
    required this.sources,
  });

  final Map<String, VideoSourceDto> sources;
}
