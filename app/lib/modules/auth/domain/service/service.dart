import 'dart:async';

abstract interface class AuthService {
  const AuthService();

  Future<void> signIn(String cookie);

  Future<void> signUp();
}
