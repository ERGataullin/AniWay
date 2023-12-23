import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/seek_gesture_detector/model.dart';
import 'package:player/src/presentation/components/seek_gesture_detector/widget.dart';
import 'package:player/src/utils/seek_gesture_recognizer.dart';
import 'package:provider/provider.dart';

SeekGestureDetectorWidgetModel seekGestureDetectorWidgetModelFactory(
  BuildContext context,
) =>
    SeekGestureDetectorWidgetModel(
      SeekGestureDetectorModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class ISeekGestureDetectorWidgetModel
    implements IWidgetModel {
  Map<Type, GestureRecognizerFactory> get gestures;
}

class SeekGestureDetectorWidgetModel
    extends WidgetModel<SeekGestureDetectorWidget, ISeekGestureDetectorModel>
    implements ISeekGestureDetectorWidgetModel {
  SeekGestureDetectorWidgetModel(super._model);

  late final ShapeBorder _inkShapeBorder = SeekGestureDetectorShapeBorder(
    widget.side,
  );

  late MaterialInkController _inkController;

  late ThemeData _theme;

  late TextDirection _textDirection;

  late DeviceGestureSettings? _gestureSettings;

  @override
  late final Map<Type, GestureRecognizerFactory> gestures = {
    SeekGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<SeekGestureRecognizer>(
      SeekGestureRecognizer.new,
      (SeekGestureRecognizer instance) {
        instance
          ..onSeekTapUp = _onSeekTapUp
          ..gestureSettings = _gestureSettings;
      },
    ),
  };

  @override
  void didChangeDependencies() {
    _inkController = Material.of(context);
    _theme = Theme.of(context);
    _textDirection = Directionality.of(context);
    _gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
  }

  void _onSeekTapUp(TapUpDetails details) {
    final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
    final Offset position = referenceBox.globalToLocal(details.globalPosition);

    _theme.splashFactory
        .create(
          controller: _inkController,
          referenceBox: referenceBox,
          position: position,
          color: _theme.splashColor,
          textDirection: _textDirection,
          containedInkWell: true,
          customBorder: _inkShapeBorder,
        )
        .confirm();

    widget.callback.call();
  }
}
