import 'package:app/movies/domain/models/watch_status.dart';

class WatchStatusDetails {
  const WatchStatusDetails({
    required this.status,
    this.score,
    this.watchedEpisodesCount = 0,
    this.comment,
  });

  final WatchStatus status;

  final int? score;

  final int watchedEpisodesCount;

  final String? comment;
}
