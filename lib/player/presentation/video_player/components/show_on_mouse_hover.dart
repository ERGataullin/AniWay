import 'dart:async';

import 'package:app/core/core.dart';
import 'package:app/player/utils/pointer_devices_accuracy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VisibilityController with ChangeNotifier {
  VisibilityController() {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  static const _hidingGap = Duration(seconds: 3);

  var _visible = false;

  Timer? _hidingTimer;

  bool get visible => _visible;

  @override
  void dispose() {
    _hidingTimer?.cancel();
    super.dispose();
  }

  void show({bool autohide = !kDebugMode}) {
    if (_visible) {
      if (_hidingTimer == null) return;
      autohide ? _restartHidingTimer() : _cancelHidingTimer();
    } else {
      _visible = true;
      notifyListeners();
      if (autohide) _restartHidingTimer();
    }
  }

  void hide({bool immediately = false}) {
    if (immediately) {
      _cancelHidingTimer();
      _visible = false;
      notifyListeners();
    } else if (_hidingTimer == null) {
      _restartHidingTimer();
    }
  }

  void toggle({bool autohide = !kDebugMode, bool immediately = false}) {
    _visible ? hide(immediately: immediately) : show(autohide: autohide);
  }

  void _restartHidingTimer() {
    _hidingTimer?.cancel();
    _hidingTimer = Timer(_hidingGap, () {
      _visible = false;
      notifyListeners();
      _hidingTimer = null;
    });
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

  final VisibilityController controller;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder:
          (context, _) => MouseRegion(
            hitTestBehavior: HitTestBehavior.translucent,
            cursor:
                controller.visible
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.none,
            onHover: (event) {
              if (event.kind.accurate) controller.show();
            },
            child: AnimatedVisibility.emphasized(
              visible: controller.visible,
              child: child,
            ),
          ),
    );
  }
}
