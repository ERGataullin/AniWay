import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HideOnUserInactivityController with ChangeNotifier {
  HideOnUserInactivityController() {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  static const Duration _hidingGap = Duration(seconds: 3);

  bool get visible => _visible;

  bool _visible = false;

  Timer? _hidingTimer;

  @override
  void dispose() {
    super.dispose();
    _hidingTimer?.cancel();
  }

  void show() {
    if (!_visible) {
      _visible = true;
      notifyListeners();
    }
    _startHidingTimer();
  }

  void startShowing() {
    if (!_visible) {
      _visible = true;
      notifyListeners();
    }
    _cancelHidingTimer();
  }

  void stopShowing() {
    if (_hidingTimer == null) {
      _startHidingTimer();
    }
  }

  void _startHidingTimer() {
    _hidingTimer?.cancel();
    _hidingTimer = Timer(
      _hidingGap,
      () {
        _visible = false;
        notifyListeners();
        _hidingTimer = null;
      },
    );
  }

  void _cancelHidingTimer() {
    _hidingTimer?.cancel();
    _hidingTimer = null;
  }
}

class ShowOnMouseHover extends StatelessWidget {
  const ShowOnMouseHover({
    super.key,
    required this.controller,
    required this.child,
  });

  final HideOnUserInactivityController controller;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, __) => MouseRegion(
        opaque: false,
        cursor: controller.visible
            ? SystemMouseCursors.basic
            : SystemMouseCursors.none,
        onHover: (_) => controller.show(),
        child: AnimatedVisibility.emphasized(
          visible: controller.visible,
          child: child,
        ),
      ),
    );
  }
}
