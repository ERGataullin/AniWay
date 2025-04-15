class VideoData {
  const VideoData({
    required this.download,
    required this.stream,
    required this.url,
    this.captionsUri,
  });

  /// Источники скачивания.
  /// Ключ - качество видео (высота в пикселях), значение - URL для скачивания.
  final Map<num, Uri> download;

  /// Источники потокового просмотра.
  /// Ключ - качество видео (высота в пикселях), значение - URL для просмотра.
  final Map<num, Uri> stream;

  final Uri url;

  final Uri? captionsUri;
}
