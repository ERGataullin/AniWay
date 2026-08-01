import 'package:app/core/core.dart';
import 'package:app/player/domain/models/seek_type.dart';
import 'package:app/player/utils/video_controller.dart';
import 'package:flutter/material.dart';

class LongSeekButton extends StatefulWidget {
  const LongSeekButton({
    super.key,
    required this.videoController,
    required this.type,
  });

  final VideoController videoController;

  final SeekType type;

  @override
  State<LongSeekButton> createState() => _LongSeekButtonState();
}

class _LongSeekButtonState extends State<LongSeekButton> {
  static const _step = Duration(minutes: 1, seconds: 30);

  late final Duration _duration = switch (widget.type) {
    .rewind => -_step,
    .fastForward => _step,
  };

  late final Computed<bool> _canSeek = .new(
    () => switch (widget.type) {
      .rewind => _videoController.position.value > Duration.zero,
      .fastForward =>
        _videoController.position.value < _videoController.duration.value,
    },
    trigger: switch (widget.type) {
      .rewind => _videoController.position,
      .fastForward => .merge([
        _videoController.position,
        _videoController.duration,
      ]),
    },
  );

  VideoController get _videoController => widget.videoController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _canSeek,
      child: switch (widget.type) {
        .rewind => const Icon(Icons.keyboard_double_arrow_left_outlined),
        .fastForward => const Icon(Icons.keyboard_double_arrow_right_outlined),
      },
      builder: (context, icon) => IconButton(
        onPressed: !_canSeek.value
            ? null
            : () => _videoController.seekTo(
                _videoController.position.value + _duration,
              ),
        icon: icon!,
      ),
    );
  }

  @override
  void dispose() {
    _canSeek.dispose();
    super.dispose();
  }
}
