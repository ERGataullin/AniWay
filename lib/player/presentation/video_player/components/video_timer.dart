import 'package:app/player/utils/video_controller.dart';
import 'package:flutter/material.dart';

extension _DurationFormat on Duration {
  String format() {
    final int hours = inHours;
    final int minutes = inMinutes % 60;
    final int seconds = inSeconds % 60;

    final buffer = StringBuffer();
    if (hours > 0) {
      buffer
        ..write(hours)
        ..write(':');
    }
    buffer
      ..write(minutes.toString().padLeft(hours > 0 ? 2 : 1, '0'))
      ..write(':')
      ..write(seconds.toString().padLeft(2, '0'));

    return buffer.toString();
  }
}

class VideoTimer extends StatelessWidget {
  const VideoTimer({super.key, required this.videoController});

  final VideoController videoController;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListenableBuilder(
      listenable: .merge([videoController.position, videoController.duration]),
      builder: (context, _) => RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: videoController.position.value.format(),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const TextSpan(text: ' / '),
            TextSpan(text: videoController.duration.value.format()),
          ],
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.secondary,
            shadows: [.new(blurRadius: 16, color: theme.colorScheme.shadow)],
          ),
        ),
      ),
    );
  }
}
