import 'package:auth/auth.dart';

class AuthRepository {
  const AuthRepository({
    required AuthDataSource local,
  }) : _local = local;

  final AuthDataSource _local;

  Future<String?> getCookies() {
    return _local.getCookies();
  }

  Future<void> saveCookies(String? value) {
    return _local.saveCookies(value);
  }
}
