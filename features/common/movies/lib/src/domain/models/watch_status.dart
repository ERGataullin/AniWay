import 'package:movies/src/data/dto/watch_status.dart';

enum WatchStatus {
  planned,
  watching,
  completed,
  onHold,
  dropped,
  none;

  factory WatchStatus.fromDto(WatchStatusDto dto) => switch (dto) {
        WatchStatusDto.planned => WatchStatus.planned,
        WatchStatusDto.watching => WatchStatus.watching,
        WatchStatusDto.completed => WatchStatus.completed,
        WatchStatusDto.onHold => WatchStatus.onHold,
        WatchStatusDto.dropped => WatchStatus.dropped,
        WatchStatusDto.none => WatchStatus.none,
      };

  WatchStatusDto toDto() => switch (this) {
        WatchStatus.planned => WatchStatusDto.planned,
        WatchStatus.watching => WatchStatusDto.watching,
        WatchStatus.completed => WatchStatusDto.completed,
        WatchStatus.onHold => WatchStatusDto.onHold,
        WatchStatus.dropped => WatchStatusDto.dropped,
        WatchStatus.none => WatchStatusDto.none,
      };
}
