class VideoData {
  const VideoData({
    required this.download,
    required this.stream,
    this.subtitlesUri,
  });

  /// Источники скачивания.
  /// Ключ - качество видео (высота в пикселях), значение - URL для скачивания.
  final Map<num, Uri> download;

  /// Источники потокового просмотра.
  /// Ключ - качество видео (высота в пикселях), значение - URL для просмотра.
  final Map<num, Uri> stream;

  final Uri? subtitlesUri;

  bool get hasSubtitles => subtitlesUri != null;
}
