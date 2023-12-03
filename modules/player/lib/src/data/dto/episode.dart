/// {@macro player.domain.models.episode.EpisodeData}
class EpisodeDto {
  const EpisodeDto({
    required this.id,
    required this.type,
    required this.number,
  });

  /// {@macro player.domain.models.episode.EpisodeData.id}
  final Object id;

  /// {@macro player.domain.models.episode.EpisodeData.type}
  final String type;

  /// {@macro player.domain.models.episode.EpisodeData.number}
  final num number;
}
