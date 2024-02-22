import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedVisibility extends StatefulWidget {
  const AnimatedVisibility.standard({
    super.key,
    this.fadeInCurve = Easing.standardDecelerate,
    this.fadeOutCurve = Easing.standardAccelerate,
    this.fadeInDuration = Durations.medium1,
    this.fadeOutDuration = Durations.short4,
    required this.visible,
    required this.child,
  });

  const AnimatedVisibility.emphasized({
    super.key,
    this.fadeInCurve = Easing.emphasizedDecelerate,
    this.fadeOutCurve = Easing.standardAccelerate,
    this.fadeInDuration = Durations.medium4,
    this.fadeOutDuration = Durations.short4,
    required this.visible,
    required this.child,
  });

  final ValueListenable<bool> visible;

  final Duration fadeInDuration;

  final Duration fadeOutDuration;

  final Curve fadeInCurve;

  final Curve fadeOutCurve;

  final Widget child;

  @override
  State<AnimatedVisibility> createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: _animationTarget,
    duration: Duration.zero,
  );

  double get _animationTarget => widget.visible.value ? 1 : 0;

  bool get _ignorePointer => !widget.visible.value;

  @override
  void initState() {
    super.initState();
    widget.visible.addListener(_animate);
    _controller.addStatusListener((status) {
      const List<AnimationStatus> boundaryStatuses = [
        AnimationStatus.completed,
        AnimationStatus.dismissed,
      ];
      if (!boundaryStatuses.contains(status)) {
        return;
      }

      setState(() {});
    });
  }

  @override
  void didUpdateWidget(AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible != oldWidget.visible) {
      oldWidget.visible.removeListener(_animate);
      widget.visible.addListener(_animate);
    }

    _animate();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: IgnorePointer(
        ignoring: _ignorePointer,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    widget.visible.removeListener(_animate);
  }

  void _animate() {
    final double target = _animationTarget;

    target > _controller.value
        ? _controller.animateTo(
            target,
            curve: widget.fadeInCurve,
            duration: widget.fadeInDuration,
          )
        : _controller.animateBack(
            target,
            curve: widget.fadeOutCurve.flipped,
            duration: widget.fadeOutDuration,
          );
  }
}
