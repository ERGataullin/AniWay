import '/app/domain/services/storage/service.dart';
import '/modules/auth/data/sources/source.dart';

class LocalAuthDataSource implements AuthDataSource {
  const LocalAuthDataSource({
    required StorageService storageService,
  }) : _storageService = storageService;

  static const String _collection = 'auth';
  static const String _authTokenKey = 'auth_token';

  final StorageService _storageService;

  @override
  Future<String?> getAuthToken() {
    return _storageService.get<String?>(
      collection: _collection,
      key: _authTokenKey,
    );
  }

  @override
  Future<void> saveAuthToken(String? authToken) {
    return _storageService.put<String?>(
      collection: _collection,
      key: _authTokenKey,
      value: authToken,
    );
  }
}
