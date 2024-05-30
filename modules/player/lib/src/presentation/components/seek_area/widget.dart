import 'dart:math';

import 'package:core/core.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/seek_area/widget_model.dart';
import 'package:video_player/video_player.dart';

typedef OnSeek = void Function(Duration duration);

enum SeekType { rewind, fastForward }

extension _SeekAreaContext on BuildContext {
  ISeekAreaWidgetModel get wm => read<ISeekAreaWidgetModel>();
}

class SeekAreaWidget extends ElementaryWidget<ISeekAreaWidgetModel> {
  const SeekAreaWidget({
    super.key,
    required this.videoController,
    required this.type,
    WidgetModelFactory wmFactory = seekAreaWidgetModelFactory,
  }) : super(wmFactory);

  final VideoPlayerController videoController;

  final SeekType type;

  @override
  Widget build(ISeekAreaWidgetModel wm) {
    return Provider.value(
      value: wm,
      child: Material(
        type: MaterialType.transparency,
        shape: SeekAreaShapeBorder(type),
        child: Builder(
          builder: (context) {
            wm.onMaterialBuilt(context);
            return ValueListenableBuilder(
              valueListenable: wm.gestures,
              builder: (context, gestures, ___) => RawGestureDetector(
                behavior: HitTestBehavior.translucent,
                gestures: gestures,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Icons(),
                    _Value(),
                  ],
                ),
              ),
            );
          },
        ),
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
      builder: (context, rotation, ___) => RotatedBox(
        quarterTurns: rotation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: context.wm.iconsOpacities
              .map(
                (animation) => ValueListenableBuilder(
                  valueListenable: animation,
                  builder: (context, opacity, ___) => Opacity(
                    opacity: opacity,
                    child: const Icon(Icons.play_arrow),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.seekValue,
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
