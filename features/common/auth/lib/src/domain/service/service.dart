import 'dart:async';

import 'package:flutter/foundation.dart';

abstract interface class AuthService {
  const AuthService();

  ValueListenable<bool> get signedIn;

  @mustCallSuper
  FutureOr<void> initialize() {}

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp();

  @mustCallSuper
  void dispose() {}
}
