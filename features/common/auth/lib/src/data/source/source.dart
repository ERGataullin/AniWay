import 'dart:async';

abstract interface class AuthDataSource {
  const AuthDataSource();

  Future<void> signIn({
    required String email,
    required String password,
  });
}
