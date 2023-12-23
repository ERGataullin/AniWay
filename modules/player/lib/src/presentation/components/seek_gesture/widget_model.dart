import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:player/src/domain/models/seek_gesture_side.dart';
import 'package:player/src/presentation/components/seek_gesture/model.dart';
import 'package:player/src/presentation/components/seek_gesture/widget.dart';
import 'package:player/src/utils/seek_gesture_recognizer.dart';
import 'package:provider/provider.dart';

SeekGestureWidgetModel seekGestureWidgetModelFactory(
  BuildContext context,
) =>
    SeekGestureWidgetModel(
      SeekGestureModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class ISeekGestureWidgetModel implements IWidgetModel {
  Map<Type, GestureRecognizerFactory> get gestures;
}

class SeekGestureWidgetModel
    extends WidgetModel<SeekGestureWidget, ISeekGestureModel>
    implements ISeekGestureWidgetModel {
  SeekGestureWidgetModel(super._model);

  static const Duration _seekValue = Duration(seconds: 10);

  late final ShapeBorder _inkShapeBorder = SeekGestureShapeBorder(
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

  Future<void> _onSeekTapUp(TapUpDetails details) async {
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

    await widget.videoController.seekTo(
      widget.videoController.value.position +
          switch (widget.side) {
            SeekGestureSide.left => -_seekValue,
            SeekGestureSide.right => _seekValue,
          },
    );
  }
}
