import 'package:player/player.dart';

class VideoData {
  const VideoData({
    required this.download,
    required this.stream,
    this.subtitlesUri,
  });

  factory VideoData.fromDto(VideoDto dto) => VideoData(
        download: dto.download
            .map((quality, url) => MapEntry(quality, Uri.parse(url))),
        stream:
            dto.stream.map((quality, url) => MapEntry(quality, Uri.parse(url))),
        subtitlesUri:
            dto.subtitlesUrl == null ? null : Uri.parse(dto.subtitlesUrl!),
      );

  /// Источники скачивания.
  /// Ключ - качество видео (высота в пикселях), значение - URL для скачивания.
  final Map<num, Uri> download;

  /// Источники потокового просмотра.
  /// Ключ - качество видео (высота в пикселях), значение - URL для просмотра.
  final Map<num, Uri> stream;

  final Uri? subtitlesUri;

  bool get hasSubtitles => subtitlesUri != null;
}
