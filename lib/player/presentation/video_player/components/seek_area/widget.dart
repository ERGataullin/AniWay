import 'dart:math';

import 'package:app/core/core.dart' hide TextDirection;
import 'package:app/l10n/l10n.dart';
import 'package:app/player/domain/models/seek_type.dart';
import 'package:app/player/presentation/video_player/components/seek_area/wm.dart';
import 'package:app/player/utils/video_controller.dart';
import 'package:flutter/material.dart';

extension _SeekAreaContext on BuildContext {
  ISeekAreaWM get wm => read<ISeekAreaWM>();
}

class SeekAreaWidget extends ElementaryWidget<ISeekAreaWM> {
  const SeekAreaWidget({
    super.key,
    required this.videoController,
    required this.type,
    WidgetModelFactory wmFactory = seekAreaWMFactory,
  }) : super(wmFactory);

  final VideoController videoController;

  final SeekType type;

  @override
  Widget build(ISeekAreaWM wm) {
    return Provider.value(
      value: wm,
      child: Stack(
        fit: .expand,
        clipBehavior: .none,
        children: [
          Material(
            type: .transparency,
            child: Column(
              key: wm.materialChildKey,
              mainAxisAlignment: .center,
              children: const [_Icons(), _Value()],
            ),
          ),
          ListenableBuilder(
            listenable: wm.gestures,
            builder: (context, _) =>
                RawGestureDetector(gestures: wm.gestures.value),
          ),
        ],
      ),
    );
  }
}

class SeekAreaShapeBorder extends ContinuousRectangleBorder {
  const SeekAreaShapeBorder(this._type);

  final SeekType _type;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double leftX = switch (_type) {
      .rewind => 0,
      .fastForward => 64,
    };
    final double rightX = switch (_type) {
      .rewind => rect.width - 64,
      .fastForward => rect.width,
    };
    final leftTop = Point<double>(leftX, rect.height);
    final leftControl = Point<double>(0, rect.height / 2);
    final leftBottom = Point<double>(leftX, 0);
    final rightTop = Point<double>(rightX, rect.height);
    final rightControl = Point<double>(rect.width, rect.height / 2);
    final rightBottom = Point<double>(rightX, 0);

    return Path()
      ..moveTo(leftTop.x, leftTop.y)
      ..conicTo(leftControl.x, leftControl.y, leftBottom.x, leftBottom.y, 1)
      ..lineTo(rightBottom.x, rightBottom.y)
      ..conicTo(rightControl.x, rightControl.y, rightTop.x, rightTop.y, 1)
      ..lineTo(leftTop.x, leftTop.y)
      ..close();
  }
}

class _Icons extends StatelessWidget {
  const _Icons();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.iconsRotation,
      builder: (context, rotation, indicators) =>
          RotatedBox(quarterTurns: rotation, child: indicators),
      child: Row(
        mainAxisSize: .min,
        children: context.wm.iconsOpacities
            .map(
              (animation) => ValueListenableBuilder(
                valueListenable: animation,
                builder: (context, opacity, _) => IgnorePointer(
                  ignoring: opacity == 0,
                  child: Opacity(
                    opacity: opacity,
                    child: const Icon(Icons.play_arrow_outlined),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.value,
      builder: (context, value, _) => AnimatedSwitcher(
        switchInCurve: Easing.standardDecelerate,
        switchOutCurve: Easing.standardAccelerate.flipped,
        duration: Durations.medium1,
        reverseDuration: Durations.short4,
        child: Text(
          value > 0 ? context.l10n.durationSeconds(value) : '',
          key: ValueKey(value),
          style: TextTheme.of(
            context,
          ).bodyLarge?.copyWith(fontFeatures: const [.tabularFigures()]),
        ),
      ),
    );
  }
}
