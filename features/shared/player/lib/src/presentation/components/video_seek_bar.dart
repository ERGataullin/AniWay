import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:player/src/utils/video_controller.dart';

class VideoSeekBar extends StatefulWidget {
  const VideoSeekBar({
    super.key,
    required this.videoController,
    this.onPositionChangeStart,
    this.onPositionChangeEnd,
  });

  final VideoController videoController;

  final ValueChanged<double>? onPositionChangeStart;

  final ValueChanged<double>? onPositionChangeEnd;

  @override
  State<VideoSeekBar> createState() => _VideoSeekBarState();
}

class _VideoSeekBarState extends State<VideoSeekBar> {
  late final DynamicData<double> _value = DynamicData(
    trigger: Listenable.merge([
      widget.videoController.position,
      widget.videoController.duration,
    ]),
    () => widget.videoController.duration.value == Duration.zero
        ? 0
        : widget.videoController.position.value.inSeconds /
            widget.videoController.duration.value.inSeconds,
  );

  bool _isMouse = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isMouse = true;
      }),
      onExit: (_) => setState(() {
        _isMouse = false;
      }),
      child: ListenableBuilder(
        listenable: _value,
        builder: (context, __) => Slider.adaptive(
          value: _value.value,
          allowedInteraction: _isMouse
              ? SliderInteraction.tapAndSlide
              : SliderInteraction.slideOnly,
          onChangeStart: widget.onPositionChangeStart,
          onChangeEnd: widget.onPositionChangeEnd,
          onChanged: (position) => widget.videoController.seekTo(
            widget.videoController.duration.value * position,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _value.dispose();
  }
}
