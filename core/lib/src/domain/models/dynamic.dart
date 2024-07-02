import 'package:flutter/foundation.dart';

class DynamicData<T> with ChangeNotifier implements ValueListenable<T> {
  DynamicData(
    this._valueResolver, {
    Listenable? trigger,
  })  : _trigger = trigger,
        _value = _valueResolver() {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
    _trigger?.addListener(update);
  }

  final T Function() _valueResolver;

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
    final T newValue = _valueResolver();
    if (newValue == value) return;
    _value = newValue;
    notifyListeners();
  }
}
