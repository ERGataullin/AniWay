import 'dart:async';

import 'package:app/core/core.dart';
import 'package:app/player/utils/pointer_devices_accuracy.dart';
import 'package:flutter/material.dart';

class Autohide extends StatefulWidget {
  const Autohide({
    super.key,
    this.background = Colors.transparent,
    required this.gestures,
    required this.controls,
  });

  final Color background;

  final Widget gestures;

  final Widget controls;

  @override
  State<Autohide> createState() => _AutohideState();
}

class _AutohideState extends State<Autohide> {
  static const _enabled = true;
  // !kDebugMode;

  var _visible = true;

  Timer? _hidingTimer;

  @override
  void initState() {
    _scheduleHiding();
    super.initState();
  }

  @override
  void dispose() {
    _hidingTimer?.cancel();
    super.dispose();
  }

  void _show() {
    _setVisibility(true);
  }

  void _hide() {
    _setVisibility(false);
  }

  void _toggle() {
    _visible ? _hide() : _show();
  }

  void _scheduleHiding() {
    _hidingTimer?.cancel();
    _hidingTimer = Timer(
      const Duration(seconds: 3),
      () => _setVisibility(false),
    );
  }

  void _setVisibility(bool value) {
    _hidingTimer?.cancel();
    if (!_enabled || _visible == value) return;
    setState(() {
      _visible = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      cursor: _visible ? SystemMouseCursors.basic : SystemMouseCursors.none,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedVisibility.emphasized(
            visible: _visible,
            child: ColoredBox(
              color: widget.background,
              child: const SizedBox.expand(),
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
                  visible: _visible,
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
