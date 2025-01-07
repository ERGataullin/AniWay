import 'package:flutter/foundation.dart';

typedef OnDisposeValue<T> = void Function(T value);

class Computed<T> with ChangeNotifier implements ValueListenable<T> {
  Computed(
    this._onCompute, {
    Listenable? trigger,
    OnDisposeValue<T>? onDisposeValue,
  })  : _trigger = trigger,
        _onDisposeValue = onDisposeValue,
        _value = _onCompute() {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
    _trigger?.addListener(update);
  }

  final T Function() _onCompute;

  final Listenable? _trigger;

  final OnDisposeValue<T>? _onDisposeValue;

  T _value;

  @override
  T get value => _value;

  void update() {
    final T oldValue = _value;
    _value = _onCompute();
    if (oldValue == _value) return;
    notifyListeners();
    _onDisposeValue?.call(oldValue);
  }

  @override
  void dispose() {
    _trigger?.removeListener(update);
    _onDisposeValue?.call(_value);
    super.dispose();
  }
}
