import 'dart:core';

import 'package:app/auth/auth.dart';
import 'package:app/core/core.dart';

abstract interface class ISignInModel implements ElementaryModel {
  bool isEmailValid(String? email);

  Future<void> signIn({
    required String email,
    required String password,
  });
}

class SignInModel extends ElementaryModel implements ISignInModel {
  SignInModel({
    super.errorHandler,
    required AuthRepository repository,
  }) : _repository = repository;

  final AuthRepository _repository;

  final _emailRegExp = RegExp(
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
    await _repository.signIn(email: email, password: password);
  }
}
