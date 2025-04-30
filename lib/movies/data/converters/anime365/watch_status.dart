import 'package:app/movies/domain/models/watch_status.dart';

abstract class WatchStatusConverterAnime365 {
  static int toJson(WatchStatus? status) {
    return switch (status) {
      WatchStatus.planned => 0,
      WatchStatus.watching => 1,
      WatchStatus.completed => 2,
      WatchStatus.onHold => 3,
      WatchStatus.dropped => 4,
      null => 99,
    };
  }
}
