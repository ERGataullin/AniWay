import 'package:app/player/utils/video_controller.dart';
import 'package:flutter/material.dart';

class VideoSeekBar extends StatefulWidget {
  const VideoSeekBar({
    super.key,
    required this.videoController,
    required this.onPositionChangeStart,
    required this.onPositionChangeEnd,
  });

  final VideoController videoController;

  final ValueChanged<double> onPositionChangeStart;

  final ValueChanged<double> onPositionChangeEnd;

  @override
  State<VideoSeekBar> createState() => _VideoSeekBarState();
}

class _VideoSeekBarState extends State<VideoSeekBar> {
  var _isMouse = false;

  var _isSeeking = false;

  var _value = 0.0;

  Duration get _position => widget.videoController.position.value;

  Duration get _duration => widget.videoController.duration.value;

  VideoController get _videoController => widget.videoController;

  @override
  void initState() {
    _videoController
      ..position.addListener(_handlePositionDurationChanged)
      ..duration.addListener(_handlePositionDurationChanged);
    super.initState();
  }

  @override
  void dispose() {
    _videoController
      ..position.removeListener(_handlePositionDurationChanged)
      ..duration.removeListener(_handlePositionDurationChanged);
    super.dispose();
  }

  void _handlePositionDurationChanged() {
    if (_isSeeking) return;
    setState(() {
      _value = switch (_duration) {
        Duration.zero => 0,
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
        allowedInteraction:
            _isMouse
                ? SliderInteraction.tapAndSlide
                : SliderInteraction.slideOnly,
        onChangeStart: (value) {
          _isSeeking = true;
          widget.onPositionChangeStart(value);
        },
        onChangeEnd: (value) {
          _isSeeking = false;
          widget.onPositionChangeEnd(value);
        },
        onChanged: (value) {
          setState(() {
            _value = value;
            _videoController.seekTo(_duration * value);
          });
        },
      ),
    );
  }
}
