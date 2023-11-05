import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '/app/domain/services/storage/service.dart';

export '/app/domain/services/storage/service.dart';

class HiveStorageService implements StorageService {
  const HiveStorageService();

  @override
  Future<void> initialize() {
    return path_provider
        .getApplicationDocumentsDirectory()
        .then((directory) => directory.path)
        .then(Hive.init);
  }

  @override
  Future<T?> get<T>({
    required String collection,
    required Object key,
    T? defaultValue,
  }) {
    return Hive.openBox<T>(collection)
        .then((box) => box.get(key, defaultValue: defaultValue));
  }

  @override
  Future<void> put<T>({
    required String collection,
    required Object key,
    required T value,
  }) {
    return Hive.openBox<T>(collection).then((box) => box.put(key, value));
  }
}
