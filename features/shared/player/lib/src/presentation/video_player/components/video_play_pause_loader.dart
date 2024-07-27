import 'package:flutter/material.dart';
import 'package:player/src/utils/video_controller.dart';

class VideoPlayPauseLoader extends StatefulWidget {
  const VideoPlayPauseLoader({
    super.key,
    required this.videoController,
  });

  final VideoController videoController;

  @override
  State<VideoPlayPauseLoader> createState() => _VideoPlayPauseLoaderState();
}

class _VideoPlayPauseLoaderState extends State<VideoPlayPauseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: Durations.medium2,
    value: widget.videoController.playing.value ? 1 : 0,
  );

  late final CurvedAnimation _animation = CurvedAnimation(
    parent: _animationController,
    curve: Easing.standard,
    reverseCurve: Easing.standard.flipped,
  );

  bool _loading = false;

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
      onPressed: _loading ? null : _handlePressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
      icon: AnimatedSwitcher(
        switchInCurve: Easing.standard,
        switchOutCurve: Easing.standard.flipped,
        duration: Durations.medium2,
        child: _loading
            ? Builder(
                builder: (context) => SizedBox.square(
                  dimension: IconTheme.of(context).size,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator.adaptive(),
                  ),
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
    super.dispose();
    _animation.dispose();
    _animationController.dispose();
    widget.videoController
      ..loading.removeListener(_update)
      ..playing.removeListener(_update);
  }

  void _handlePressed() {
    widget.videoController.playPause();
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
