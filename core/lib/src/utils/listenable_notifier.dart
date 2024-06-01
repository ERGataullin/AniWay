import 'package:flutter/foundation.dart';

class ListenableNotifier<T> with ChangeNotifier implements ValueListenable<T> {
  ListenableNotifier(this._listenable, this._computation)
      : _value = _computation() {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
    _listenable.addListener(_onListenableChanged);
  }

  final Listenable _listenable;

  final T Function() _computation;

  T _value;

  @override
  T get value => _value;

  @override
  void dispose() {
    _listenable.removeListener(_onListenableChanged);
    super.dispose();
  }

  void _onListenableChanged() {
    final T newValue = _computation();
    if (newValue == value) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }
}
