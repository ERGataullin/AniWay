import 'package:auth/auth.dart';
import 'package:core/core.dart';

class StorageAuthDataSource implements AuthDataSource {
  const StorageAuthDataSource({
    required Storage storage,
  }) : _storage = storage;

  static const String _collection = 'auth';

  static const String _cookiesKey = 'cookies';

  final Storage _storage;

  @override
  Future<String?> getCookies() {
    return _storage.get<String?>(
      collection: _collection,
      key: _cookiesKey,
    );
  }

  @override
  Future<void> saveCookies(String? value) {
    return _storage.put<String?>(
      collection: _collection,
      key: _cookiesKey,
      value: value,
    );
  }
}
