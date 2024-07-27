import 'dart:async';

import 'package:auth/auth.dart';

class AuthRepository {
  const AuthRepository({
    required AuthDataSource remote,
  }) : _remote = remote;

  final AuthDataSource _remote;

  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _remote.signIn(
      email: email,
      password: password,
    );
  }
}
