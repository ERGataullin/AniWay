import 'package:core/core.dart';
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
  ValueListenable<Map<Type, GestureRecognizerFactory>> get gestures;

  ValueListenable<ShapeBorder> get shape;

  ValueListenable<int> get indicatorRotationQuarterTurns;

  ValueListenable<String> get indicatorValue;

  List<Animation<double>> get indicatorIconsAnimations;

  void onMaterialBuilt(BuildContext context);
}

class SeekGestureWidgetModel
    extends WidgetModel<SeekGestureWidget, ISeekGestureModel>
    with TickerProviderWidgetModelMixin
    implements ISeekGestureWidgetModel {
  SeekGestureWidgetModel(super._model);

  static const int _indicatorIconsCount = 3;

  @override
  final ValueNotifier<Map<Type, GestureRecognizerFactory>> gestures =
      ValueNotifier(const {});

  @override
  final ValueNotifier<ShapeBorder> shape = ValueNotifier(
    const RoundedRectangleBorder(),
  );

  @override
  final ValueNotifier<int> indicatorRotationQuarterTurns = ValueNotifier(0);

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

  bool _indicatorVisible = false;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..canSeek.addListener(_updateGestures)
      ..value.addListener(_onValueChaged)
      ..side = widget.side
      ..videoController = widget.videoController;
    shape.value = SeekGestureShapeBorder(widget.side);
    indicatorRotationQuarterTurns.value = switch (widget.side) {
      Side.left => 2,
      Side.right => 0,
    };
    _updateGestures();
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
    model
      ..videoController = widget.videoController
      ..side = widget.side;
    shape.value = SeekGestureShapeBorder(widget.side);
    indicatorRotationQuarterTurns.value = switch (widget.side) {
      Side.left => 2,
      Side.right => 0,
    };
  }

  @override
  void dispose() {
    super.dispose();
    model
      ..canSeek.removeListener(_updateGestures)
      ..value.removeListener(_onValueChaged);
    gestures.dispose();
    shape.dispose();
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
    model.seek();

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
  }

  Future<void> _onSeekTapCancel() async {
    model.submit();
  }

  Future<void> _onValueChaged() async {
    _indicatorVisible = model.value.value != Duration.zero;
    if (!_indicatorVisible) {
      for (final AnimationController iconController
          in _indicatorIconsControllers) {
        await iconController.forward();
      }
      for (final AnimationController iconController
          in _indicatorIconsControllers) {
        await iconController.reverse();
      }
    }
    _updateIndicatorValue();
    if (_indicatorVisible) {
      for (final AnimationController iconController
          in _indicatorIconsControllers) {
        await iconController.forward();
      }
    }
  }

  void _updateGestures() {
    gestures.value = model.canSeek.value
        ? {
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
          }
        : const {};
  }

  void _updateIndicatorValue() {
    indicatorValue.value = model.value.value == Duration.zero
        ? ''
        : _localizations.seekGestureSeekValue(model.value.value.inSeconds);
  }
}
