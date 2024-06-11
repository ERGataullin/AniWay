class VideoDto {
  const VideoDto({
    required this.download,
    required this.stream,
    this.subtitlesUrl,
  });

  /// Источники скачивания.
  /// Ключ - качество видео (высота в пикселях), значение - URL для скачивания.
  final Map<num, String> download;

  /// Источники потокового просмотра.
  /// Ключ - качество видео (высота в пикселях), значение - URL для просмотра.
  final Map<num, String> stream;

  final String? subtitlesUrl;
}
