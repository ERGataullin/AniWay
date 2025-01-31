/// Изображение.
///
/// Может иметь экземпляры в различных разрешениях.
class ImageData {
  const ImageData({required this.resolutionsUris});

  /// Набор изображений в различных разрешениях.
  ///
  /// Ключ - ширина изображений в физических пикселях.
  /// Значение - URI изображения.
  final Map<num, Uri> resolutionsUris;
}
