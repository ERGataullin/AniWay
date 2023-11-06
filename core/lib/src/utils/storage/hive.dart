import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HiveStorage implements Storage {
  const HiveStorage();

  @override
  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    final String? storagePath = kIsWeb
        ? null
        : await path_provider
            .getApplicationDocumentsDirectory()
            .then((directory) => directory.path);

    Hive.init(storagePath);
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
