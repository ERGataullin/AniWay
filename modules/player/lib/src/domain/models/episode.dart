import 'package:player/player.dart';

/// {@template player.domain.models.episode.EpisodeTypeData}
/// Тип эпизода.
/// {@endtemplate}
enum EpisodeTypeData {
  /// Трейлер.
  preview,

  /// Обычный эпизод.
  tv,

  /// OVA.
  ova,

  /// ONA.
  ona,

  /// Спешл.
  special;
}

/// {@template player.domain.models.episode.EpisodeData}
/// Эпизод фильма/сериала.
/// {@endtemplate}
class EpisodeData {
  const EpisodeData({
    required this.id,
    required this.type,
    required this.number,
  });

  /// Создание эпизода из соответствующего [EpisodeDto].
  factory EpisodeData.fromDto(EpisodeDto dto) => EpisodeData(
        id: dto.id,
        type: switch (dto.type) {
          'preview' => EpisodeTypeData.preview,
          'tv' => EpisodeTypeData.tv,
          'ova' => EpisodeTypeData.ova,
          'ona' => EpisodeTypeData.ona,
          'special' => EpisodeTypeData.special,
          _ => throw UnsupportedError('Unsupported episode type: ${dto.type}'),
        },
        number: dto.number,
      );

  /// {@template player.domain.models.episode.EpisodeData.id}
  /// Идентификатор.
  /// {@endtemplate}
  final Object id;

  /// {@template player.domain.models.episode.EpisodeData.type}
  /// Тип: трейлер, обычный эпизод, OVA, ONA, спешл.
  /// {@endtemplate}
  final EpisodeTypeData type;

  /// {@template player.domain.models.episode.EpisodeData.number}
  /// Порядковый номер.
  /// {@endtemplate}
  final num number;
}
