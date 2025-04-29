import 'package:flutter/material.dart';

class AnimatedVisibility extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: fadeInCurve,
      switchOutCurve: fadeOutCurve,
      duration: fadeInDuration,
      reverseDuration: fadeOutDuration,
      child: visible ? child : null,
    );
  }
}
