import 'dart:async';

import 'package:app/core/core.dart';
import 'package:app/player/utils/pointer_devices_accuracy.dart';
import 'package:app/player/utils/video_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _VisibilityReason { loading, paused, userInteraction }

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
  final _visibilityReasons = <_VisibilityReason>{};

  Timer? _visibilityReasonsChangeTimer;

  var _visible = false;

  @override
  void initState() {
    widget.videoController
      ..loading.addListener(_handleLoadingPlayingChanged)
      ..playing.addListener(_handleLoadingPlayingChanged);
    _handleLoadingPlayingChanged();
    super.initState();
  }

  @override
  void dispose() {
    widget.videoController
      ..loading.removeListener(_handleLoadingPlayingChanged)
      ..playing.removeListener(_handleLoadingPlayingChanged);
    _visibilityReasonsChangeTimer?.cancel();
    super.dispose();
  }

  void _changeVisibilityReasons({
    Set<_VisibilityReason> add = const {},
    Set<_VisibilityReason> remove = const {},
    bool delayRemove = true,
  }) {
    if (add.isEmpty && remove.isEmpty) return;
    _visibilityReasonsChangeTimer?.cancel();

    _visibilityReasons
      ..addAll(add)
      ..removeAll(remove);

    final bool visibleNew = _visibilityReasons.isNotEmpty;
    if (visibleNew == _visible) return;

    if (visibleNew || !delayRemove) {
      _setVisibility(visibleNew);
    } else {
      _visibilityReasonsChangeTimer = Timer(
        const Duration(seconds: 2),
        () => _setVisibility(visibleNew),
      );
    }
  }

  void _setVisibility(bool visible) {
    setState(() {
      _visible = visible;
      SystemChrome.setEnabledSystemUIMode(
        _visible ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
      );
    });
  }

  void _handleLoadingPlayingChanged() {
    _changeVisibilityReasons(
      add: {
        if (widget.videoController.loading.value) _VisibilityReason.loading,
        if (!widget.videoController.playing.value) _VisibilityReason.paused,
      },
      remove: {
        if (!widget.videoController.loading.value) _VisibilityReason.loading,
        if (widget.videoController.playing.value) _VisibilityReason.paused,
      },
    );
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
              visible: _visible,
              child: ColoredBox(
                color: widget.background,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          _InaccuratePointerListener(
            onTap: () {
              _changeVisibilityReasons(
                add: {if (!_visible) _VisibilityReason.userInteraction},
                remove: {if (_visible) ..._VisibilityReason.values},
                delayRemove: false,
              );
            },
            onUserInteractionStart: () {
              _changeVisibilityReasons(
                add: const {_VisibilityReason.userInteraction},
              );
            },
            onUserInteractionEnd: () {
              _changeVisibilityReasons(
                remove: const {_VisibilityReason.userInteraction},
              );
            },
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
          _AccuratePointerListener(
            onUserInteractionStart: () {
              _changeVisibilityReasons(
                add: const {_VisibilityReason.userInteraction},
              );
            },
            onUserInteractionEnd: () {
              _changeVisibilityReasons(
                remove: const {_VisibilityReason.userInteraction},
              );
            },
            onPointerOut: () {
              _changeVisibilityReasons(
                remove: const {_VisibilityReason.userInteraction},
                delayRemove: false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AccuratePointerListener extends StatelessWidget {
  const _AccuratePointerListener({
    required this.onUserInteractionStart,
    required this.onUserInteractionEnd,
    required this.onPointerOut,
  });

  final VoidCallback onUserInteractionStart;

  final VoidCallback onUserInteractionEnd;

  final VoidCallback onPointerOut;

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
              if (event.kind.accurate) onUserInteractionStart();
            },
            onPointerHover: (event) {
              if (!event.kind.accurate || event.down) return;
              if (pointerHoverSensitivityRect.contains(event.localPosition)) {
                onUserInteractionStart();
                onUserInteractionEnd();
              } else {
                onPointerOut();
              }
            },
            onPointerUp: (event) {
              if (event.kind.accurate) onUserInteractionEnd();
            },
          ),
        );
      },
    );
  }
}

class _InaccuratePointerListener extends StatelessWidget {
  const _InaccuratePointerListener({
    required this.onTap,
    required this.onUserInteractionStart,
    required this.onUserInteractionEnd,
    required this.child,
  });

  final VoidCallback onTap;

  final VoidCallback onUserInteractionStart;

  final VoidCallback onUserInteractionEnd;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          supportedDevices: PointerDevicesAccuracy.inaccurateDevices,
          onTap: onTap,
        ),
        child,
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (event.kind.accurate) onUserInteractionStart();
          },
          onPointerUp: (event) {
            if (!event.kind.accurate) onUserInteractionEnd();
          },
        ),
      ],
    );
  }
}
