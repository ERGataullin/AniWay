import 'dart:math';

import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:player/src/domain/models/seek_gesture_detector_side.dart';
import 'package:player/src/presentation/components/seek_gesture_detector/widget_model.dart';

class SeekGestureDetectorWidget
    extends ElementaryWidget<ISeekGestureDetectorWidgetModel> {
  const SeekGestureDetectorWidget({
    super.key,
    required this.side,
    required this.callback,
    WidgetModelFactory wmFactory = seekGestureDetectorWidgetModelFactory,
  }) : super(wmFactory);

  final SeekGestureDetectorSide side;

  final VoidCallback callback;

  @override
  Widget build(ISeekGestureDetectorWidgetModel wm) {
    // return Placeholder();
    // return GestureDetector(
    //   // customBorder: _SeekGestureDetectorShapeBorder(side),
    //   onDoubleTap: () {},
    // );
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: wm.gestures,
    );
  }
}

class SeekGestureDetectorShapeBorder extends ContinuousRectangleBorder {
  const SeekGestureDetectorShapeBorder(this._side);

  final SeekGestureDetectorSide _side;

  @override
  Path getOuterPath(
    Rect rect, {
    TextDirection? textDirection,
  }) {
    final Point<double> leftTop = Point(
      switch (_side) {
        SeekGestureDetectorSide.left => 0,
        SeekGestureDetectorSide.right => 64,
      },
      rect.height,
    );
    final Point<double> leftControl = Point(0, rect.height / 2);
    final Point<double> leftBottom = Point(
      switch (_side) {
        SeekGestureDetectorSide.left => 0,
        SeekGestureDetectorSide.right => 64,
      },
      0,
    );
    final Point<double> rightTop = Point(
      switch (_side) {
        SeekGestureDetectorSide.left => rect.width - 64,
        SeekGestureDetectorSide.right => rect.width,
      },
      rect.height,
    );
    final Point<double> rightControl = Point(rect.width, rect.height / 2);
    final Point<double> rightBottom = Point(
      switch (_side) {
        SeekGestureDetectorSide.left => rect.width - 64,
        SeekGestureDetectorSide.right => rect.width,
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
