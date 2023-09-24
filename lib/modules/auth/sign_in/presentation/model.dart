import 'dart:async';

import 'package:elementary/elementary.dart';

class SignInModel extends ElementaryModel {
  SignInModel(
    ErrorHandler errorHandler, {
    required this.onSignedIn,
  }) : super(errorHandler: errorHandler);

  final void Function() onSignedIn;

  Future<void> signIn() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    onSignedIn();
  }
}
