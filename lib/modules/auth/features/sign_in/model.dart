import 'dart:async';

import 'package:elementary/elementary.dart';

abstract interface class ISignInModel implements ElementaryModel {
  Future<void> signIn();
}

class SignInModel extends ElementaryModel implements ISignInModel {
  SignInModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);

  @override
  Future<void> signIn() async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
