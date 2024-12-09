import 'package:flutter/foundation.dart';

class DynamicData<T> with ChangeNotifier implements ValueListenable<T> {
  factory DynamicData(
    T Function() valueResolver, {
    Listenable? trigger,
  }) {
    return DynamicData.initialValue(
      valueResolver,
      initialValue: valueResolver(),
      trigger: trigger,
    );
  }

  DynamicData.initialValue(
    this._valueResolver, {
    required T initialValue,
    Listenable? trigger,
  })  : _trigger = trigger,
        _value = initialValue {
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
