import 'package:core/core.dart';

class ImageData {
  const ImageData({required this.uri});

  factory ImageData.fromDto(ImageDto dto) => ImageData(
        uri: dto.url.map(
          (key, value) => MapEntry(key, Uri.parse(value)),
        ),
      );

  /// Набор изображений в различных разрешениях.
  ///
  /// Ключ - ширина изображений в физических пикселях.
  /// Значение - URI изображения.
  final Map<num, Uri> uri;
}
