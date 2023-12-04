import 'package:player/player.dart';

enum EpisodeTypeData {
  preview,

  tv,

  ova,

  ona,

  special;
}

class EpisodeData {
  const EpisodeData({
    required this.id,
    required this.type,
    required this.number,
  });

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

  final Object id;

  final EpisodeTypeData type;

  final num number;
}
