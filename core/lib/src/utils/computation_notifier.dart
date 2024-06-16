import 'package:flutter/foundation.dart';

class ComputationNotifier<T> with ChangeNotifier implements ValueListenable<T> {
  ComputationNotifier(
    this._computation, {
    Listenable? trigger,
  })  : _trigger = trigger,
        _value = _computation() {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
    _trigger?.addListener(update);
  }

  final T Function() _computation;

  Listenable? _trigger;

  T _value;

  @override
  T get value => _value;

  set trigger(Listenable value) {
    if (_trigger == value) return;

    _trigger?.removeListener(update);
    _trigger = value..addListener(update);
    update();
  }

  @override
  void dispose() {
    _trigger?.removeListener(update);
    super.dispose();
  }

  void update() {
    final T newValue = _computation();
    if (newValue == value) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }
}
