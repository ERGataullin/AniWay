import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ShimmerScopeAnimationController extends AnimationController {
  ShimmerScopeAnimationController({
    super.value,
    required super.vsync,
  }) : super.unbounded();

  final Set<VoidCallback> _listeners = {};

  final ValueNotifier<bool> _hasClients = ValueNotifier(false);

  ValueListenable<bool> get hasClients => _hasClients;

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    _hasClients.value = true;
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    _hasClients.value = _listeners.isNotEmpty;
    super.removeListener(listener);
  }

  @override
  void dispose() {
    _listeners.clear();
    _hasClients.dispose();
    super.dispose();
  }
}
