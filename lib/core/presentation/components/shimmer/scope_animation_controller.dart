import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ShimmerScopeAnimationController extends AnimationController {
  ShimmerScopeAnimationController({super.value, required super.vsync})
    : super.unbounded();

  final Set<VoidCallback> _listeners = {};

  final ValueNotifier<bool> _hasClients = .new(false);

  ValueListenable<bool> get hasClients => _hasClients;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _listeners.add(listener);
    _hasClients.value = true;
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (_listeners.remove(listener)) {
      _hasClients.value = _listeners.isNotEmpty;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _hasClients.dispose();
  }
}
