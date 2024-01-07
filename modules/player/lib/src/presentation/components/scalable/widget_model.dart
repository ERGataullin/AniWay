import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/scalable/model.dart';
import 'package:player/src/presentation/components/scalable/widget.dart';
import 'package:provider/provider.dart';

ScalableWidgetModel scalableWidgetModelFactory(BuildContext context) =>
    ScalableWidgetModel(
      ScalableModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class IScalableWidgetModel implements IWidgetModel {
  ValueListenable<double> get scale;

  void onScaleUpdate(ScaleUpdateDetails details);

  void onScaleEnd(ScaleEndDetails details);
}

class ScalableWidgetModel extends WidgetModel<ScalableWidget, IScalableModel>
    implements IScalableWidgetModel {
  ScalableWidgetModel(super._model);

  @override
  ValueListenable<double> get scale => model.scale;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..minScale = widget.minScale
      ..maxScale = widget.maxScale
      ..anchors = widget.anchors;
  }

  @override
  void didUpdateWidget(ScalableWidget oldWidget) {
    model
      ..minScale = widget.minScale
      ..maxScale = widget.maxScale
      ..anchors = widget.anchors;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails details) {
    model.updateScale(details.scale);
  }

  @override
  void onScaleEnd(ScaleEndDetails details) {
    model.submitScale();
  }
}
