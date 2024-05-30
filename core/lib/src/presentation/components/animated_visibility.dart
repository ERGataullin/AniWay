import 'package:flutter/material.dart';

class AnimatedVisibility extends StatefulWidget {
  AnimatedVisibility.standard({
    super.key,
    this.fadeInCurve = Easing.standardDecelerate,
    Curve? fadeOutCurve,
    this.fadeInDuration = Durations.medium1,
    this.fadeOutDuration = Durations.short4,
    required this.visible,
    required this.child,
  }) : fadeOutCurve = fadeOutCurve ?? Easing.standardAccelerate.flipped;

  AnimatedVisibility.emphasized({
    super.key,
    this.fadeInCurve = Easing.emphasizedDecelerate,
    Curve? fadeOutCurve,
    this.fadeInDuration = Durations.medium4,
    this.fadeOutDuration = Durations.short4,
    required this.visible,
    required this.child,
  }) : fadeOutCurve = fadeOutCurve ?? Easing.emphasizedAccelerate.flipped;

  final bool visible;

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

  double get _animationTarget => widget.visible ? 1 : 0;

  bool get _ignorePointer => !widget.visible;

  @override
  void initState() {
    super.initState();
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
      _animate();
    }
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
