import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:player/player.dart';
import 'package:player/src/domain/models/side.dart';
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
  ValueListenable<ShapeBorder> get shape;

  ValueListenable<int> get indicatorRotationQuarterTurns;

  ValueListenable<bool> get showIndicatorValue;

  ValueListenable<String> get indicatorValue;

  List<Animation<double>> get indicatorIconsAnimations;

  Map<Type, GestureRecognizerFactory> get gestures;

  void onMaterialBuilt(BuildContext context);
}

class SeekGestureWidgetModel
    extends WidgetModel<SeekGestureWidget, ISeekGestureModel>
    with TickerProviderWidgetModelMixin
    implements ISeekGestureWidgetModel {
  SeekGestureWidgetModel(super._model);

  static const Duration _seekStep = Duration(seconds: 10);

  static const int _indicatorIconsCount = 3;

  @override
  final ValueNotifier<ShapeBorder> shape = ValueNotifier(
    const RoundedRectangleBorder(),
  );

  @override
  final ValueNotifier<int> indicatorRotationQuarterTurns = ValueNotifier(0);

  @override
  final ValueNotifier<bool> showIndicatorValue = ValueNotifier(false);

  @override
  final ValueNotifier<String> indicatorValue = ValueNotifier('');

  @override
  late final List<CurvedAnimation> indicatorIconsAnimations =
      _indicatorIconsControllers
          .map(
            (controller) => CurvedAnimation(
              parent: controller.view,
              curve: Easing.standardDecelerate,
              reverseCurve: Easing.standardAccelerate.flipped,
            ),
          )
          .toList(growable: false);

  late final List<AnimationController> _indicatorIconsControllers =
      List.generate(
    _indicatorIconsCount,
    (_) => AnimationController(
      vsync: this,
      value: showIndicatorValue.value ? 1 : 0,
      duration: Duration(
        milliseconds: Durations.medium1.inMilliseconds ~/ _indicatorIconsCount,
      ),
      reverseDuration: Duration(
        milliseconds: Durations.short4.inMilliseconds ~/ _indicatorIconsCount,
      ),
    ),
  );

  late MaterialInkController _inkController;

  late ThemeData _theme;

  late TextDirection _textDirection;

  late DeviceGestureSettings? _gestureSettings;

  Duration _currentValue = Duration.zero;

  @override
  late final Map<Type, GestureRecognizerFactory> gestures = {
    SeekGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<SeekGestureRecognizer>(
      SeekGestureRecognizer.new,
      (SeekGestureRecognizer instance) {
        instance
          ..onSeekTapUp = _onSeekTapUp
          ..onSeekTapCancel = _onSeekTapCancel
          ..gestureSettings = _gestureSettings;
      },
    ),
  };

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    shape.value = SeekGestureShapeBorder(widget.side);
    indicatorRotationQuarterTurns.value = switch (widget.side) {
      Side.left => 2,
      Side.right => 0,
    };
  }

  @override
  void didChangeDependencies() {
    _theme = Theme.of(context);
    _textDirection = Directionality.of(context);
    _gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
  }

  @override
  void onMaterialBuilt(BuildContext context) {
    _inkController = Material.of(context);
  }

  @override
  void didUpdateWidget(SeekGestureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    shape.value = SeekGestureShapeBorder(widget.side);
    indicatorRotationQuarterTurns.value = switch (widget.side) {
      Side.left => 2,
      Side.right => 0,
    };
  }

  @override
  void dispose() {
    super.dispose();
    shape.dispose();
    showIndicatorValue.dispose();
    indicatorRotationQuarterTurns.dispose();
    indicatorValue.dispose();
    for (final CurvedAnimation animation in indicatorIconsAnimations) {
      animation.dispose();
    }
    for (final AnimationController controller in _indicatorIconsControllers) {
      controller.dispose();
    }
  }

  Future<void> _onSeekTapUp(TapUpDetails details) async {
    widget.videoController.seekTo(
      widget.videoController.value.position +
          switch (widget.side) {
            Side.left => -_seekStep,
            Side.right => _seekStep,
          },
    );

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
          customBorder: shape.value,
        )
        .confirm();

    _currentValue += _seekStep;
    showIndicatorValue.value = true;
    indicatorValue.value = context.localizations.componentsSeekGestureSeekValue(
      _currentValue.inSeconds,
    );
    for (final AnimationController iconController
        in _indicatorIconsControllers) {
      await iconController.forward();
    }
  }

  Future<void> _onSeekTapCancel() async {
    await Future<void>.delayed(
      (_indicatorIconsControllers[0].duration ?? Duration.zero) -
          kDoubleTapTimeout,
    );

    _currentValue = Duration.zero;
    showIndicatorValue.value = false;
    indicatorValue.value = '';
    for (final AnimationController iconController
        in _indicatorIconsControllers) {
      await iconController.reverse();
    }
  }
}
