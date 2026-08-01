import 'package:app/player/utils/video_controller.dart';
import 'package:flutter/material.dart';

class VideoSeekBar extends StatefulWidget {
  const VideoSeekBar({super.key, required this.videoController});

  final VideoController videoController;

  @override
  State<VideoSeekBar> createState() => _VideoSeekBarState();
}

class _VideoSeekBarState extends State<VideoSeekBar> {
  var _isMouse = false;

  var _value = 0.0;

  Duration get _position => widget.videoController.position.value;

  Duration get _duration => widget.videoController.duration.value;

  VideoController get _videoController => widget.videoController;

  @override
  void initState() {
    _videoController
      ..position.addListener(_updateValue)
      ..duration.addListener(_updateValue);
    _updateValue();
    super.initState();
  }

  @override
  void dispose() {
    _videoController
      ..position.removeListener(_updateValue)
      ..duration.removeListener(_updateValue);
    super.dispose();
  }

  void _updateValue() {
    setState(() {
      _value = switch (_duration) {
        .zero => 0,
        final Duration duration =>
          _position.inMicroseconds / duration.inMicroseconds,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isMouse = true),
      onExit: (_) => setState(() => _isMouse = false),
      child: Slider.adaptive(
        value: _value,
        allowedInteraction: _isMouse
            ? SliderInteraction.tapAndSlide
            : SliderInteraction.slideOnly,
        onChanged: (value) {
          setState(() => _videoController.seekTo(_duration * value));
        },
      ),
    );
  }
}
