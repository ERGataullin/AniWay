import 'dart:core';

import 'package:auth/auth.dart';
import 'package:core/core.dart';

abstract interface class ISignInModel implements ElementaryModel {
  bool isEmailValid(String? email);

  Future<void> signIn({
    required String email,
    required String password,
  });
}

class SignInModel extends ElementaryModel implements ISignInModel {
  SignInModel(
    ErrorHandler errorHandler, {
    required AuthService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  final AuthService _service;

  final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
    r'[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  @override
  bool isEmailValid(String? email) {
    return email?.contains(_emailRegExp) ?? false;
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _service.signIn(email: email, password: password);
  }
}
