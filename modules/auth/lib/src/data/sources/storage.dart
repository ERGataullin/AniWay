import 'package:auth/auth.dart';
import 'package:core/core.dart';

class StorageAuthDataSource implements AuthDataSource {
  const StorageAuthDataSource({
    required Storage storage,
  }) : _storage = storage;

  static const String _collection = 'auth';
  static const String _authTokenKey = 'auth_token';

  final Storage _storage;

  @override
  Future<String?> getAuthToken() {
    return _storage.get<String?>(
      collection: _collection,
      key: _authTokenKey,
    );
  }

  @override
  Future<void> saveAuthToken(String? authToken) {
    return _storage.put<String?>(
      collection: _collection,
      key: _authTokenKey,
      value: authToken,
    );
  }
}
