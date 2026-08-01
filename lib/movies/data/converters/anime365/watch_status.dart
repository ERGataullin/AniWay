import 'package:app/movies/domain/models/watch_status.dart';

abstract class WatchStatusConverterAnime365 {
  static int toJson(WatchStatus? status) {
    return switch (status) {
      .planned => 0,
      .watching => 1,
      .completed => 2,
      .onHold => 3,
      .dropped => 4,
      null => 99,
    };
  }
}
