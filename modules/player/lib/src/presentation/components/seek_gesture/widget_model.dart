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

  ValueListenable<Map<Type, GestureRecognizerFactory>> get gestures;

  ValueListenable<int> get indicatorRotationQuarterTurns;

  ValueListenable<bool> get showIndicatorValue;

  ValueListenable<String> get indicatorValue;

  List<Animation<double>> get indicatorIconsAnimations;

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
  final ValueNotifier<Map<Type, GestureRecognizerFactory>> gestures =
      ValueNotifier(const {});

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

  late PlayerLocalizations _localizations;

  Duration _currentValue = Duration.zero;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    widget.videoController.addListener(_onVideoControllerValueChanged);
    _updateGestures();
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
    _localizations = PlayerLocalizations.of(context);
  }

  @override
  void onMaterialBuilt(BuildContext context) {
    _inkController = Material.of(context);
  }

  @override
  void didUpdateWidget(SeekGestureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoController != oldWidget.videoController) {
      oldWidget.videoController.removeListener(_onVideoControllerValueChanged);
      widget.videoController.addListener(_onVideoControllerValueChanged);
    }
    _updateGestures();
    shape.value = SeekGestureShapeBorder(widget.side);
    indicatorRotationQuarterTurns.value = switch (widget.side) {
      Side.left => 2,
      Side.right => 0,
    };
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoController.removeListener(_onVideoControllerValueChanged);
    gestures.dispose();
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
    indicatorValue.value = _localizations.componentsSeekGestureSeekValue(
      _currentValue.inSeconds,
    );
    for (final AnimationController iconController
        in _indicatorIconsControllers) {
      await iconController.forward();
    }
  }

  Future<void> _onSeekTapCancel() async {
    if (_currentValue == Duration.zero) {
      return;
    }

    _currentValue = Duration.zero;
    for (final AnimationController iconController
        in _indicatorIconsControllers) {
      await iconController.forward();
    }
    for (final AnimationController iconController
        in _indicatorIconsControllers) {
      await iconController.reverse();
    }
    showIndicatorValue.value = false;
    indicatorValue.value = '';
  }

  void _updateGestures() {
    gestures.value = widget.videoController.value.position == Duration.zero ||
            widget.videoController.value.position ==
                widget.videoController.value.duration
        ? const {}
        : {
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
  }

  void _onVideoControllerValueChanged() {
    _updateGestures();
  }
}
