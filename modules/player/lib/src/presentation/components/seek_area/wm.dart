import 'package:core/core.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/components/seek_area/model.dart';
import 'package:player/src/presentation/components/seek_area/widget.dart';
import 'package:player/src/utils/seek_gesture_recognizer.dart';

SeekAreaWM seekAreaWMFactory(BuildContext context) => SeekAreaWM(
      SeekAreaModel(context.read<ErrorHandler>()),
    );

abstract interface class ISeekAreaWM implements IWidgetModel {
  ValueListenable<Map<Type, GestureRecognizerFactory>> get gestures;

  ValueListenable<ShapeBorder> get shape;

  ValueListenable<String> get seekValue;

  ValueListenable<int> get iconsRotation;

  List<Animation<double>> get iconsOpacities;

  void onMaterialBuilt(BuildContext context);
}

class SeekAreaWM extends WidgetModel<SeekAreaWidget, ISeekAreaModel>
    with TickerProviderWidgetModelMixin
    implements ISeekAreaWM {
  SeekAreaWM(super._model);

  static const int _iconsCount = 3;

  @override
  final ValueNotifier<Map<Type, GestureRecognizerFactory>> gestures =
      ValueNotifier(const {});

  @override
  final ValueNotifier<ShapeBorder> shape = ValueNotifier(
    const RoundedRectangleBorder(),
  );

  @override
  final ValueNotifier<String> seekValue = ValueNotifier('');

  @override
  final ValueNotifier<int> iconsRotation = ValueNotifier(0);

  @override
  late final List<CurvedAnimation> iconsOpacities = _iconsControllers
      .map(
        (controller) => CurvedAnimation(
          parent: controller,
          curve: Easing.standardDecelerate,
          reverseCurve: Easing.standardAccelerate.flipped,
        ),
      )
      .toList(growable: false);

  late final List<AnimationController> _iconsControllers = List.generate(
    _iconsCount,
    (_) => AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: Durations.medium1.inMilliseconds ~/ _iconsCount,
      ),
      reverseDuration: Duration(
        milliseconds: Durations.short4.inMilliseconds ~/ _iconsCount,
      ),
    ),
  );

  late MaterialInkController _inkController;

  late ThemeData _theme;

  late TextDirection _textDirection;

  late DeviceGestureSettings? _gestureSettings;

  late PlayerLocalizations _localizations;

  bool _visible = false;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..addListener(_onModelChaged)
      ..type = widget.type
      ..videoController = widget.videoController;
    shape.value = SeekAreaShapeBorder(widget.type);
    iconsRotation.value = switch (widget.type) {
      SeekType.rewind => 2,
      SeekType.fastForward => 0,
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
  void didUpdateWidget(SeekAreaWidget oldWidget) {
    model
      ..type = widget.type
      ..videoController = widget.videoController;
    shape.value = SeekAreaShapeBorder(widget.type);
    iconsRotation.value = switch (widget.type) {
      SeekType.rewind => 2,
      SeekType.fastForward => 0,
    };
    _updateGestures();
  }

  @override
  void dispose() {
    gestures.dispose();
    shape.dispose();
    iconsRotation.dispose();
    seekValue.dispose();
    for (final CurvedAnimation animation in iconsOpacities) {
      animation.dispose();
    }
    for (final AnimationController controller in _iconsControllers) {
      controller.dispose();
    }
    super.dispose();
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

  Future<void> _onModelChaged() async {
    _visible = model.value != Duration.zero;
    if (!_visible) {
      for (final AnimationController iconController in _iconsControllers) {
        await iconController.forward();
      }
      for (final AnimationController iconController in _iconsControllers) {
        await iconController.reverse();
      }
    }
    _updateValue();
    if (_visible) {
      for (final AnimationController iconController in _iconsControllers) {
        await iconController.forward();
      }
    }
    _updateGestures();
  }

  void _updateGestures() {
    gestures.value = model.canSeek
        ? {
            SeekGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<SeekGestureRecognizer>(
              SeekGestureRecognizer.new,
              (SeekGestureRecognizer instance) => instance
                ..onSeekTapUp = _onSeekTapUp
                ..onSeekTapCancel = _onSeekTapCancel
                ..gestureSettings = _gestureSettings,
            ),
          }
        : const {};
  }

  void _updateValue() {
    seekValue.value = model.value == Duration.zero
        ? ''
        : _localizations.seekAreaSeekValue(model.value.inSeconds);
  }
}
