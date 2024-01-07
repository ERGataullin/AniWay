import 'dart:core';
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

abstract interface class IScalableModel implements ElementaryModel {
  ValueListenable<double> get scale;

  set minScale(double value);

  set maxScale(double value);

  set anchors(List<double> value);

  void updateScale(double scale);

  void submitScale();
}

class ScalableModel extends ElementaryModel implements IScalableModel {
  ScalableModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);

  @override
  final ValueNotifier<double> scale = ValueNotifier(1);

  @override
  set minScale(double value) {
    _minScale = value;
    scale.value = max(value, scale.value);
  }

  @override
  set maxScale(double value) {
    _maxScale = value;
    scale.value = min(value, scale.value);
  }

  @override
  set anchors(List<double> value) => _anchors = value;

  double _minScale = 1;

  double _maxScale = 1;

  List<double> _anchors = const [];

  late double _submittedScale = scale.value;

  @override
  void updateScale(double value) {
    scale.value = max(
      _minScale,
      min(_maxScale, _submittedScale * value),
    );
  }

  @override
  void submitScale() {
    double? closestAnchor;
    num? closestAnchorDistance;
    for (final double anchor in _anchors) {
      final num distance = (anchor - scale.value).abs();
      if (distance < (closestAnchorDistance ?? .1)) {
        closestAnchor = anchor;
        closestAnchorDistance = distance;
      }
    }

    if (closestAnchor != null) {
      scale.value = closestAnchor;
    }

    _submittedScale = scale.value;
  }

  @override
  void dispose() {
    super.dispose();
    scale.dispose();
  }
}
