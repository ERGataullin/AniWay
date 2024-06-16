import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

abstract interface class AuthService implements Initable {
  const AuthService();

  ValueListenable<bool> get signedIn;

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp();
}
