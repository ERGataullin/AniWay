import 'package:player/player.dart';

class VideoSourceData {
  const VideoSourceData({
    required this.quality,
    required this.uri,
  });

  factory VideoSourceData.fromDto(VideoSourceDto dto) => VideoSourceData(
        quality: dto.quality,
        uri: Uri.parse(dto.url),
      );

  final String quality;

  final Uri uri;
}
