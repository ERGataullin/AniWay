import 'package:movies/src/data/dto/watch_list_element.dart';
import 'package:movies/src/domain/models/watch_status.dart';

class WatchListElementData {
  const WatchListElementData({
    required this.status,
    this.score,
    required this.watchedEpisodesCount,
    this.episodesCount,
  });

  factory WatchListElementData.fromDto(WatchListElementDto dto) =>
      WatchListElementData(
        status: WatchStatus.fromDto(dto.status),
        score: dto.score,
        watchedEpisodesCount: dto.watchedEpisodesCount ?? 0,
        episodesCount: dto.episodesCount,
      );

  final WatchStatus status;

  final int? score;

  final int watchedEpisodesCount;

  final int? episodesCount;
}
