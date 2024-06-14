import 'dart:async';

import 'package:flutter/foundation.dart';

abstract interface class AuthService {
  const AuthService();

  ValueListenable<bool> get signedIn;

  Future<void> init();

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp();

  void dispose();
}
