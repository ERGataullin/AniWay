import 'dart:core';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;

abstract interface class ISignInModel implements ElementaryModel {
  Future<void> signIn(String cookie);
}

class SignInModel extends ElementaryModel implements ISignInModel {
  SignInModel(
    ErrorHandler errorHandler, {
    required AuthService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  final AuthService _service;

  @override
  Future<void> signIn(String cookie) {
    return _service.signIn(cookie);
  }
}