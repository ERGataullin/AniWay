import 'package:app/features/movies/domain/models/watch_status.dart';

class WatchListElementData {
  const WatchListElementData({
    required this.status,
    this.score,
    this.watchedEpisodesCount = 0,
    this.episodesCount,
  });

  final WatchStatus status;

  final int? score;

  final int watchedEpisodesCount;

  final int? episodesCount;
}
