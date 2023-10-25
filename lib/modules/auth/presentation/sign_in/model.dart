import 'dart:async';

import 'package:elementary/elementary.dart';

import '/modules/auth/domain/service/service.dart';

abstract interface class ISignInModel implements ElementaryModel {
  Future<void> signIn();
}

class SignInModel extends ElementaryModel implements ISignInModel {
  SignInModel(
    ErrorHandler errorHandler, {
    required AuthService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  final AuthService _service;

  @override
  Future<void> signIn() {
    return _service.signIn(
      email: 'email',
      password: 'password',
    );
  }
}
