import 'package:app/core/core.dart' hide TextDirection;
import 'package:app/player/domain/models/seek_type.dart';
import 'package:app/player/presentation/video_player/components/seek_area/model.dart';
import 'package:app/player/presentation/video_player/components/seek_area/widget.dart';
import 'package:app/player/utils/pointer_devices_accuracy.dart';
import 'package:app/player/utils/seek_gesture_recognizer.dart';
import 'package:app/player/utils/video_controller.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

SeekAreaWM seekAreaWMFactory(BuildContext context) =>
    SeekAreaWM(SeekAreaModel(errorHandler: context.read<ErrorHandler>()));

abstract interface class ISeekAreaWM implements IWidgetModel {
  ValueListenable<Map<Type, GestureRecognizerFactory>> get gestures;

  ValueListenable<ShapeBorder> get shape;

  ValueListenable<int> get value;

  ValueListenable<int> get iconsRotation;

  List<Animation<double>> get iconsOpacities;

  Key? get materialChildKey;
}

class SeekAreaWM extends WidgetModel<SeekAreaWidget, ISeekAreaModel>
    with ThemeWMMixin, TickerProviderWidgetModelMixin
    implements ISeekAreaWM {
  SeekAreaWM(super._model);

  static const _iconsCount = 3;

  @override
  final GlobalKey materialChildKey = GlobalKey();

  @override
  late final Computed<Map<Type, GestureRecognizerFactory>> gestures = Computed(
    trigger: Listenable.merge([
      _videoController.position,
      _videoController.duration,
    ]),
    () =>
        model.canSeek(
              seekType: widget.type,
              position: _videoController.position.value,
              duration: _videoController.duration.value,
            )
            ? {
              SeekGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<SeekGestureRecognizer>(
                    SeekGestureRecognizer.new,
                    (instance) =>
                        instance
                          ..supportedDevices =
                              PointerDevicesAccuracy.inaccurateDevices
                          ..onSeekTapUp = _handleSeekTapUp
                          ..onSeekTapCancel = _handleSeekTapCancel
                          ..gestureSettings = _gestureSettings,
                  ),
            }
            : const {},
  );

  @override
  late final Computed<ShapeBorder> shape = Computed(
    () => SeekAreaShapeBorder(widget.type),
  );

  @override
  late final Computed<int> value = Computed(
    trigger: model.value,
    () => model.value.value.inSeconds,
  );

  @override
  late final Computed<int> iconsRotation = Computed(
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
    model.value.addListener(_handleValueChaged);
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

  Future<void> _handleSeekTapUp(TapUpDetails details) async {
    model.incrementValue(seekType: widget.type);
    _videoController.seekTo(
      model.getSeekPosition(
        seekType: widget.type,
        position: _videoController.position.value,
      ),
    );

    final referenceBox = context.findRenderObject()! as RenderBox;
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

  Future<void> _handleSeekTapCancel() async {
    if (!context.mounted) return;
    model.resetValue();
  }

  Future<void> _handleValueChaged() async {
    final visible = model.value.value != Duration.zero;
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
