import 'dart:math';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:player/src/domain/models/side.dart';
import 'package:player/src/presentation/components/seek_gesture/widget_model.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:provider/provider.dart';

extension _SeekGestureContext on BuildContext {
  ISeekGestureWidgetModel get wm => read<ISeekGestureWidgetModel>();
}

class SeekGestureWidget extends ElementaryWidget<ISeekGestureWidgetModel> {
  const SeekGestureWidget({
    super.key,
    required this.side,
    required this.videoController,
    WidgetModelFactory wmFactory = seekGestureWidgetModelFactory,
  }) : super(wmFactory);

  final Side side;

  final VideoController videoController;

  @override
  Widget build(ISeekGestureWidgetModel wm) {
    return Provider.value(
      value: wm,
      child: Material(
        type: MaterialType.transparency,
        shape: SeekGestureShapeBorder(side),
        child: Builder(
          builder: (context) {
            wm.onMaterialBuilt(context);
            return RawGestureDetector(
              behavior: HitTestBehavior.translucent,
              gestures: wm.gestures,
              child: const _Indicator(),
            );
          },
        ),
      ),
    );
  }
}

class SeekGestureShapeBorder extends ContinuousRectangleBorder {
  const SeekGestureShapeBorder(this._side);

  final Side _side;

  @override
  Path getOuterPath(
    Rect rect, {
    TextDirection? textDirection,
  }) {
    final Point<double> leftTop = Point(
      switch (_side) {
        Side.left => 0,
        Side.right => 64,
      },
      rect.height,
    );
    final Point<double> leftControl = Point(0, rect.height / 2);
    final Point<double> leftBottom = Point(
      switch (_side) {
        Side.left => 0,
        Side.right => 64,
      },
      0,
    );
    final Point<double> rightTop = Point(
      switch (_side) {
        Side.left => rect.width - 64,
        Side.right => rect.width,
      },
      rect.height,
    );
    final Point<double> rightControl = Point(rect.width, rect.height / 2);
    final Point<double> rightBottom = Point(
      switch (_side) {
        Side.left => rect.width - 64,
        Side.right => rect.width,
      },
      0,
    );

    return Path()
      ..moveTo(leftTop.x, leftTop.y)
      ..conicTo(leftControl.x, leftControl.y, leftBottom.x, leftBottom.y, 1)
      ..lineTo(rightBottom.x, rightBottom.y)
      ..conicTo(rightControl.x, rightControl.y, rightTop.x, rightTop.y, 1)
      ..lineTo(leftTop.x, leftTop.y)
      ..close();
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _IndicatorIcons(),
        _IndicatorValue(),
      ],
    );
  }
}

class _IndicatorIcons extends StatelessWidget {
  const _IndicatorIcons();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.indicatorRotationQuarterTurns,
      builder: (context, rotationQuarterTurns, ___) => RotatedBox(
        quarterTurns: rotationQuarterTurns,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: context.wm.indicatorIconsAnimations
              .map(
                (animation) => ValueListenableBuilder<double>(
                  valueListenable: animation,
                  child: const Icon(Icons.play_arrow),
                  builder: (context, opacity, icon) => Opacity(
                    opacity: opacity,
                    child: icon!,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _IndicatorValue extends StatelessWidget {
  const _IndicatorValue();

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility.standard(
      visible: context.wm.showIndicatorValue,
      child: ValueListenableBuilder(
        valueListenable: context.wm.indicatorValue,
        builder: (context, value, ___) => Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFeatures: const [
              FontFeature.tabularFigures(),
            ],
          ),
        ),
      ),
    );
  }
}
