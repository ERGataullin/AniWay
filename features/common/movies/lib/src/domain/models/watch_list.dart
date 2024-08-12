import 'package:movies/src/data/dto/watch_list_element.dart';
import 'package:movies/src/domain/models/watch_status.dart';

class WatchListElementData {
  const WatchListElementData({
    required this.status,
    this.score,
    this.countWatchedEpisodes,
    this.countEpisodes,
  });

  factory WatchListElementData.fromDto(WatchListElementDto dto) =>
      WatchListElementData(
        status: WatchStatus.fromDto(dto.status),
        score: dto.score,
        countWatchedEpisodes: dto.countWatchedEpisodes,
        countEpisodes: dto.countEpisodes,
      );

  final WatchStatus status;

  final int? score;

  final int? countWatchedEpisodes;

  final int? countEpisodes;
}
