import 'dart:math';

import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:player/src/domain/models/seek_gesture_side.dart';
import 'package:player/src/presentation/components/seek_gesture/widget_model.dart';
import 'package:player/src/utils/video_controller.dart';

class SeekGestureWidget extends ElementaryWidget<ISeekGestureWidgetModel> {
  const SeekGestureWidget({
    super.key,
    required this.side,
    required this.videoController,
    WidgetModelFactory wmFactory = seekGestureWidgetModelFactory,
  }) : super(wmFactory);

  final SeekGestureSide side;

  final VideoController videoController;

  @override
  Widget build(ISeekGestureWidgetModel wm) {
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: wm.gestures,
    );
  }
}

class SeekGestureShapeBorder extends ContinuousRectangleBorder {
  const SeekGestureShapeBorder(this._side);

  final SeekGestureSide _side;

  @override
  Path getOuterPath(
    Rect rect, {
    TextDirection? textDirection,
  }) {
    final Point<double> leftTop = Point(
      switch (_side) {
        SeekGestureSide.left => 0,
        SeekGestureSide.right => 64,
      },
      rect.height,
    );
    final Point<double> leftControl = Point(0, rect.height / 2);
    final Point<double> leftBottom = Point(
      switch (_side) {
        SeekGestureSide.left => 0,
        SeekGestureSide.right => 64,
      },
      0,
    );
    final Point<double> rightTop = Point(
      switch (_side) {
        SeekGestureSide.left => rect.width - 64,
        SeekGestureSide.right => rect.width,
      },
      rect.height,
    );
    final Point<double> rightControl = Point(rect.width, rect.height / 2);
    final Point<double> rightBottom = Point(
      switch (_side) {
        SeekGestureSide.left => rect.width - 64,
        SeekGestureSide.right => rect.width,
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
