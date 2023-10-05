import '/modules/auth/data/sources/source.dart';

class LocalAuthDataSource implements AuthDataSource {
  const LocalAuthDataSource();

  @override
  Future<String?> getAuthToken() {
    return Future.value(
      'This is the token read from the local database',
    );
  }

  @override
  Future<void> saveAuthToken(String? authToken) {
    throw UnimplementedError();
  }
}
