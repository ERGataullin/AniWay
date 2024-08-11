import 'package:movies/src/data/dto/watch_status.dart';

class WatchListElementDto {
  WatchListElementDto({
    required this.status,
    this.score,
    this.countWatchedEpisodes,
    this.countEpisodes,
  });

  final WatchStatusDto status;

  final int? score;

  final int? countWatchedEpisodes;

  final int? countEpisodes;
}
