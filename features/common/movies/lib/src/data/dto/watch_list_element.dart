import 'package:movies/src/data/dto/watch_status.dart';

class WatchListElementDto {
  const WatchListElementDto({
    required this.status,
    this.score,
    this.watchedEpisodesCount,
    this.episodesCount,
  });

  final WatchStatusDto status;

  final int? score;

  final int? watchedEpisodesCount;

  final int? episodesCount;
}
