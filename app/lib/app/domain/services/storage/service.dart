import 'dart:async';

abstract interface class StorageService {
  const StorageService();

  Future<void> initialize();

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
