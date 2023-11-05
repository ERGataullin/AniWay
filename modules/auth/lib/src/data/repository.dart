import 'package:auth/auth.dart';

class AuthRepository {
  const AuthRepository({
    required AuthDataSource local,
  }) : _local = local;

  final AuthDataSource _local;

  Future<String?> getAuthToken() {
    return _local.getAuthToken();
  }

  Future<void> saveAuthToken(String authToken) {
    return _local.saveAuthToken(authToken);
  }
}
