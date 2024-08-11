import 'package:movies/src/domain/models/watch_status.dart';

class WatchListElementData {
  const WatchListElementData({
    required this.status,
    this.score,
    this.countWatchedEpisodes,
    this.countEpisodes,
  });

  factory WatchListElementData.fromDto(WatchListElementData dto) =>
      WatchListElementData(
        status: dto.status,
        score: dto.score,
        countWatchedEpisodes: dto.countWatchedEpisodes,
        countEpisodes: dto.countEpisodes,
      );

  final WatchStatus status;

  final int? score;

  final int? countWatchedEpisodes;

  final int? countEpisodes;
}
