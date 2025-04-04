import 'package:app/movies/domain/models/watch_status.dart';

class WatchStatusDetails {
  const WatchStatusDetails(
    this.status, {
    this.score,
    this.episodesCount = 0,
    this.comment,
  });

  final WatchStatus status;

  final int? score;

  final int episodesCount;

  final String? comment;
}
