import 'package:app/core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HiveService implements StorageService {
  const HiveService();

  @override
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    final String? storagePath =
        kIsWeb
            ? null
            : await path_provider.getApplicationDocumentsDirectory().then(
              (directory) => directory.path,
            );

    Hive.init(storagePath);
  }

  @override
  Future<T> get<T>({
    required String collection,
    required Object key,
    required T defaultValue,
  }) async {
    final Box<T> box = await Hive.openBox(collection);
    return box.get(key, defaultValue: defaultValue) as T;
  }

  @override
  Future<void> put<T>({
    required String collection,
    required Object key,
    required T value,
  }) {
    return Hive.openBox<T>(collection).then((box) => box.put(key, value));
  }

  @override
  Future<void> dispose() {
    return Hive.close();
  }
}
