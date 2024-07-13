import 'dart:math';

import 'package:core/core.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:player/src/domain/models/seek_type.dart';
import 'package:player/src/presentation/video_player/components/seek_area/wm.dart';
import 'package:player/src/utils/video_controller.dart';

extension _SeekAreaContext on BuildContext {
  ISeekAreaWM get wm => read<ISeekAreaWM>();
}

class SeekAreaWidget extends ElementaryWidget<ISeekAreaWM> {
  const SeekAreaWidget({
    super.key,
    required this.videoController,
    required this.type,
    WidgetModelFactory wmFactory = seekAreaWMFactory,
  }) : super(wmFactory);

  final VideoController videoController;

  final SeekType type;

  @override
  Widget build(ISeekAreaWM wm) {
    return Provider.value(
      value: wm,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          ListenableBuilder(
            listenable: wm.shape,
            builder: (context, child) => Material(
              type: MaterialType.transparency,
              shape: wm.shape.value,
              child: child,
            ),
            child: Column(
              key: wm.materialChildKey,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _Icons(),
                _Value(),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: wm.gestures,
            builder: (context, __) => RawGestureDetector(
              gestures: wm.gestures.value,
            ),
          ),
        ],
      ),
    );
  }
}

class SeekAreaShapeBorder extends ContinuousRectangleBorder {
  const SeekAreaShapeBorder(this._type);

  final SeekType _type;

  @override
  Path getOuterPath(
    Rect rect, {
    TextDirection? textDirection,
  }) {
    final double leftX = switch (_type) {
      SeekType.rewind => 0,
      SeekType.fastForward => 64,
    };
    final double rightX = switch (_type) {
      SeekType.rewind => rect.width - 64,
      SeekType.fastForward => rect.width,
    };
    final Point<double> leftTop = Point(leftX, rect.height);
    final Point<double> leftControl = Point(0, rect.height / 2);
    final Point<double> leftBottom = Point(leftX, 0);
    final Point<double> rightTop = Point(rightX, rect.height);
    final Point<double> rightControl = Point(rect.width, rect.height / 2);
    final Point<double> rightBottom = Point(rightX, 0);

    return Path()
      ..moveTo(leftTop.x, leftTop.y)
      ..conicTo(leftControl.x, leftControl.y, leftBottom.x, leftBottom.y, 1)
      ..lineTo(rightBottom.x, rightBottom.y)
      ..conicTo(rightControl.x, rightControl.y, rightTop.x, rightTop.y, 1)
      ..lineTo(leftTop.x, leftTop.y)
      ..close();
  }
}

class _Icons extends StatelessWidget {
  const _Icons();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.iconsRotation,
      builder: (context, rotation, indicators) => RotatedBox(
        quarterTurns: rotation,
        child: indicators,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: context.wm.iconsOpacities
            .map(
              (animation) => ValueListenableBuilder(
                valueListenable: animation,
                builder: (context, opacity, ___) => IgnorePointer(
                  ignoring: opacity == 0,
                  child: Opacity(
                    opacity: opacity,
                    child: const Icon(Icons.play_arrow),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.value,
      builder: (context, value, ___) => AnimatedSwitcher(
        switchInCurve: Easing.standardDecelerate,
        switchOutCurve: Easing.standardAccelerate.flipped,
        duration: Durations.medium1,
        reverseDuration: Durations.short4,
        child: Text(
          value,
          key: Key(value),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
