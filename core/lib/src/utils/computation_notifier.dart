import 'package:flutter/foundation.dart';

class ComputationNotifier<T> with ChangeNotifier implements ValueListenable<T> {
  ComputationNotifier({
    Listenable? trigger,
    required T Function() computation,
  })  : _trigger = trigger,
        _computation = computation,
        _value = computation() {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
    _trigger?.addListener(update);
  }

  final Listenable? _trigger;

  final T Function() _computation;

  T _value;

  @override
  T get value => _value;

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
