import 'package:app/player/utils/video_controller.dart';
import 'package:flutter/material.dart';

class VideoPlayPauseLoader extends StatefulWidget {
  const VideoPlayPauseLoader({super.key, required this.videoController});

  final VideoController videoController;

  @override
  State<VideoPlayPauseLoader> createState() => _VideoPlayPauseLoaderState();
}

class _VideoPlayPauseLoaderState extends State<VideoPlayPauseLoader>
    with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    duration: Durations.medium2,
    value: widget.videoController.playing.value ? 1 : 0,
  );

  late final _animation = CurvedAnimation(
    parent: _animationController,
    curve: Easing.standard,
    reverseCurve: Easing.standard.flipped,
  );

  var _loading = false;

  @override
  void initState() {
    super.initState();
    widget.videoController
      ..loading.addListener(_update)
      ..playing.addListener(_update);
    _update();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      iconSize: 48,
      onPressed: _loading ? null : widget.videoController.playPause,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          ColorScheme.of(context).secondaryContainer,
        ),
      ),
      icon: AnimatedSwitcher(
        switchInCurve: Easing.standard,
        switchOutCurve: Easing.standard.flipped,
        duration: Durations.medium2,
        child:
            _loading
                ? Builder(
                  builder:
                      (context) => SizedBox.square(
                        dimension: IconTheme.of(context).size,
                        child: const CircularProgressIndicator.adaptive(),
                      ),
                )
                : AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _animation,
                ),
      ),
    );
  }

  @override
  void dispose() {
    widget.videoController
      ..loading.removeListener(_update)
      ..playing.removeListener(_update);
    _animation.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _update() {
    setState(() {
      widget.videoController.playing.value
          ? _animationController.forward(from: _loading ? 1 : null)
          : _animationController.reverse(from: _loading ? 0 : null);
      _loading = widget.videoController.loading.value;
    });
  }
}
