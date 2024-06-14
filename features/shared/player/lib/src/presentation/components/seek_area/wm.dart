import 'package:core/core.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:player/src/presentation/components/seek_area/model.dart';
import 'package:player/src/presentation/components/seek_area/widget.dart';
import 'package:player/src/utils/seek_gesture_recognizer.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:theme/theme.dart';

SeekAreaWM seekAreaWMFactory(BuildContext context) => SeekAreaWM(
      SeekAreaModel(context.read<ErrorHandler>()),
    );

abstract interface class ISeekAreaWM implements IWidgetModel {
  ValueListenable<Map<Type, GestureRecognizerFactory>> get gestures;

  ValueListenable<ShapeBorder> get shape;

  ValueListenable<String> get value;

  ValueListenable<int> get iconsRotation;

  List<Animation<double>> get iconsOpacities;

  Key? get materialChildKey;
}

class SeekAreaWM extends WidgetModel<SeekAreaWidget, ISeekAreaModel>
    with L10nWMMixin, ThemeWMMixin, TickerProviderWidgetModelMixin
    implements ISeekAreaWM {
  SeekAreaWM(super._model);

  static const int _iconsCount = 3;

  @override
  final GlobalKey materialChildKey = GlobalKey();

  @override
  late final ComputationNotifier<Map<Type, GestureRecognizerFactory>> gestures =
      ComputationNotifier(
    trigger: Listenable.merge([
      _videoController.position,
      _videoController.duration,
    ]),
    () => model.canSeek(
      seekType: widget.type,
      position: _videoController.position.value,
      duration: _videoController.duration.value,
    )
        ? {
            SeekGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<SeekGestureRecognizer>(
              SeekGestureRecognizer.new,
              (instance) => instance
                ..onSeekTapUp = _onSeekTapUp
                ..onSeekTapCancel = _onSeekTapCancel
                ..gestureSettings = _gestureSettings,
            ),
          }
        : const {},
  );

  @override
  late final ComputationNotifier<ShapeBorder> shape = ComputationNotifier(
    () => SeekAreaShapeBorder(widget.type),
  );

  @override
  late final ComputationNotifier<String> value = ComputationNotifier(
    trigger: model.value,
    () => model.value.value == Duration.zero
        ? ''
        : l10n.value.durationSeconds(model.value.value.inSeconds),
  );

  @override
  late final ComputationNotifier<int> iconsRotation = ComputationNotifier(
    () => switch (widget.type) {
      SeekType.rewind => 2,
      SeekType.fastForward => 0,
    },
  );

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

  late TextDirection _textDirection;

  late DeviceGestureSettings? _gestureSettings;

  VideoController get _videoController => widget.videoController;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model.value.addListener(_onValueChaged);
    shape.update();
    iconsRotation.update();
  }

  @override
  void didChangeDependencies() {
    _textDirection = Directionality.of(context);
    _gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    gestures.dispose();
    shape.dispose();
    iconsRotation.dispose();
    value.dispose();
    for (final CurvedAnimation animation in iconsOpacities) {
      animation.dispose();
    }
    for (final AnimationController controller in _iconsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _onSeekTapUp(TapUpDetails details) async {
    model.incrementValue();
    _videoController.seekTo(
      model.getSeekPosition(
        seekType: widget.type,
        position: _videoController.position.value,
      ),
    );

    final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
    final Offset position = referenceBox.globalToLocal(details.globalPosition);

    theme.value.splashFactory
        .create(
          controller: Material.of(materialChildKey.currentContext!),
          referenceBox: referenceBox,
          position: position,
          color: theme.value.splashColor,
          textDirection: _textDirection,
          containedInkWell: true,
          customBorder: shape.value,
        )
        .confirm();
  }

  Future<void> _onSeekTapCancel() async {
    model.resetValue();
  }

  Future<void> _onValueChaged() async {
    final bool visible = model.value.value != Duration.zero;
    if (visible) {
      for (final AnimationController iconController in _iconsControllers) {
        await iconController.forward();
      }
    } else {
      for (final AnimationController iconController in _iconsControllers) {
        await iconController.reverse();
      }
    }
  }
}
