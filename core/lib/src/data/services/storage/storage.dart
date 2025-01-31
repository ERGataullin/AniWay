import 'dart:async';

import 'package:core/core.dart';

abstract interface class StorageService implements Initable {
  const StorageService();

  Future<T> get<T>({
    required String collection,
    required Object key,
    required T defaultValue,
  });

  Future<void> put<T>({
    required String collection,
    required Object key,
    required T value,
  });
}
