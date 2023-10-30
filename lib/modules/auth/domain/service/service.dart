import 'dart:async';

abstract interface class AuthService {
  const AuthService();

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp();
}
