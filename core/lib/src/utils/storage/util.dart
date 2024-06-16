import 'dart:async';

import 'package:core/core.dart';

abstract interface class Storage implements Initable {
  const Storage();

  Future<T?> get<T>({
    required String collection,
    required Object key,
    T? defaultValue,
  });

  Future<void> put<T>({
    required String collection,
    required Object key,
    required T value,
  });
}
