import 'dart:async';

import 'package:app/core/core.dart';
import 'package:app/player/utils/pointer_devices_accuracy.dart';
import 'package:app/player/utils/video_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Autohide extends StatefulWidget {
  const Autohide({
    super.key,
    required this.videoController,
    this.background = Colors.transparent,
    required this.controls,
    required this.gestures,
    required this.playerBuilder,
  });

  final VideoController videoController;

  final Color background;

  final Widget controls;

  final Widget gestures;

  final Widget Function(BuildContext context, Widget background) playerBuilder;

  @override
  State<Autohide> createState() => _AutohideState();
}

class _AutohideState extends State<Autohide> {
  var _visible = false;

  var _forceVisible = false;

  Timer? _hidingTimer;

  bool get _effectiveVisible => _forceVisible || _visible;

  @override
  void initState() {
    widget.videoController
      ..loading.addListener(_handleForceVisibleUpdate)
      ..playing.addListener(_handleForceVisibleUpdate);
    _handleForceVisibleUpdate();
    _scheduleHiding();
    super.initState();
  }

  @override
  void dispose() {
    widget.videoController
      ..loading.removeListener(_handleForceVisibleUpdate)
      ..playing.removeListener(_handleForceVisibleUpdate);
    _hidingTimer?.cancel();
    super.dispose();
  }

  void _show() {
    _setVisibility(visible: true);
  }

  void _hide() {
    _setVisibility(visible: false);
  }

  void _toggle() {
    _visible ? _hide() : _show();
  }

  void _scheduleHiding({bool force = false}) {
    if (_forceVisible && !force) return;
    _hidingTimer?.cancel();
    _hidingTimer = Timer(
      const Duration(seconds: 2),
      () => _setVisibility(visible: false, forceVisible: false),
    );
  }

  void _setVisibility({bool? visible, bool? forceVisible}) {
    _hidingTimer?.cancel();

    if ((visible == null || visible == _visible) &&
        (forceVisible == null || forceVisible == _forceVisible)) {
      return;
    }

    setState(() {
      _visible = visible ?? _visible;
      _forceVisible = forceVisible ?? _forceVisible;
      SystemChrome.setEnabledSystemUIMode(
        _effectiveVisible
            ? SystemUiMode.edgeToEdge
            : SystemUiMode.immersiveSticky,
      );
    });
  }

  void _handleForceVisibleUpdate() {
    final bool value =
        widget.videoController.loading.value ||
        !widget.videoController.playing.value;
    if (_forceVisible == value) return;
    value ? _setVisibility(forceVisible: true) : _scheduleHiding(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      cursor: _visible ? SystemMouseCursors.basic : SystemMouseCursors.none,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.playerBuilder(
            context,
            AnimatedVisibility.emphasized(
              visible: _effectiveVisible,
              child: ColoredBox(
                color: widget.background,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          _InaccuratePointerDevicesListener(
            onToggle: _toggle,
            onScheduleHiding: _scheduleHiding,
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.gestures,
                AnimatedVisibility.emphasized(
                  visible: _effectiveVisible,
                  child: widget.controls,
                ),
              ],
            ),
          ),
          _AccuratePointerDevicesListener(
            onShow: _show,
            onHide: _hide,
            onScheduleHiding: _scheduleHiding,
          ),
        ],
      ),
    );
  }
}

class _AccuratePointerDevicesListener extends StatelessWidget {
  const _AccuratePointerDevicesListener({
    required this.onShow,
    required this.onHide,
    required this.onScheduleHiding,
  });

  final VoidCallback onShow;

  final VoidCallback onHide;

  final VoidCallback onScheduleHiding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = constraints.biggest;
        final pointerHoverSensitivityRect = Rect.fromPoints(
          const Offset(1, 1),
          Offset(size.width - 1, size.height - 1),
        );

        return SizedBox.fromSize(
          size: size,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              if (event.kind.accurate) onShow();
            },
            onPointerHover: (event) {
              if (!event.kind.accurate || event.down) return;
              if (pointerHoverSensitivityRect.contains(event.localPosition)) {
                onShow();
                onScheduleHiding();
              } else {
                onHide();
              }
            },
            onPointerUp: (event) {
              if (event.kind.accurate) onScheduleHiding();
            },
          ),
        );
      },
    );
  }
}

class _InaccuratePointerDevicesListener extends StatelessWidget {
  const _InaccuratePointerDevicesListener({
    required this.onToggle,
    required this.onScheduleHiding,
    required this.child,
  });

  final VoidCallback onToggle;

  final VoidCallback onScheduleHiding;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          supportedDevices: PointerDevicesAccuracy.inaccurateDevices,
          onTap: () {
            onToggle();
            onScheduleHiding();
          },
        ),
        child,
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (!event.kind.accurate) onScheduleHiding();
          },
          onPointerMove: (event) {
            if (!event.kind.accurate) onScheduleHiding();
          },
          onPointerUp: (event) {
            if (!event.kind.accurate) onScheduleHiding();
          },
        ),
      ],
    );
  }
}
