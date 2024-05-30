import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoSeekBar extends StatefulWidget {
  const VideoSeekBar({
    super.key,
    required this.videoController,
    this.onPositionChangeStart,
    this.onPositionChangeEnd,
  });

  final VideoPlayerController videoController;

  final ValueChanged<double>? onPositionChangeStart;

  final ValueChanged<double>? onPositionChangeEnd;

  @override
  State<VideoSeekBar> createState() => _VideoSeekBarState();
}

class _VideoSeekBarState extends State<VideoSeekBar> {
  double _value = 0;

  bool _isMouse = false;

  @override
  void initState() {
    super.initState();
    widget.videoController.addListener(_update);
    _update();
  }

  @override
  void didUpdateWidget(covariant VideoSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoController != oldWidget.videoController) {
      oldWidget.videoController.removeListener(_update);
      widget.videoController.addListener(_update);
      _update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isMouse = true;
      }),
      onExit: (_) => setState(() {
        _isMouse = false;
      }),
      child: Slider.adaptive(
        value: _value,
        allowedInteraction: _isMouse
            ? SliderInteraction.tapAndSlide
            : SliderInteraction.slideOnly,
        onChangeStart: widget.onPositionChangeStart,
        onChangeEnd: widget.onPositionChangeEnd,
        onChanged: (position) => widget.videoController.seekTo(
          widget.videoController.value.duration * position,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoController.removeListener(_update);
  }

  void _update() {
    setState(() {
      _value = widget.videoController.value.duration == Duration.zero
          ? 0
          : widget.videoController.value.position.inSeconds /
              widget.videoController.value.duration.inSeconds;
    });
  }
}
