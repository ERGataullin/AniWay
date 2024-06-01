import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

extension _DurationFormat on Duration {
  String format() {
    final int hours = inHours;
    final int minutes = inMinutes % 60;
    final int seconds = inSeconds % 60;

    final StringBuffer buffer = StringBuffer();
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
  const VideoTimer({
    super.key,
    required this.videoController,
  });

  final VideoPlayerController videoController;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListenableBuilder(
      listenable: videoController,
      builder: (context, __) => RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: videoController.value.position.format(),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const TextSpan(text: ' / '),
            TextSpan(text: videoController.value.duration.format()),
          ],
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.secondary,
            shadows: [
              Shadow(
                blurRadius: 16,
                color: Theme.of(context).colorScheme.shadow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
