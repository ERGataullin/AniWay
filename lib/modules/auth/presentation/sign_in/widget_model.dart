import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/app/domain/services/error_handle/service.dart';
import '/modules/auth/domain/service.dart';
import '/modules/auth/presentation/sign_in/model.dart';
import '/modules/auth/presentation/sign_in/widget.dart';

SignInWidgetModel signInWidgetModelFactory(BuildContext context) =>
    SignInWidgetModel(
      SignInModel(
        context.read<ErrorHandleService>(),
        service: context.read<AuthService>(),
      ),
    );

abstract interface class ISignInWidgetModel implements IWidgetModel {
  String get title;

  TextEditingController get emailFieldController;

  String get emailFieldLabel;

  String get signInButtonLabel;

  void onSignInButtonPressed();
}

class SignInWidgetModel extends WidgetModel<SignInWidget, ISignInModel>
    implements ISignInWidgetModel {
  SignInWidgetModel(super._model);

  @override
  final String title = 'Sign in';

  @override
  final TextEditingController emailFieldController = TextEditingController();

  @override
  final String emailFieldLabel = 'Email';

  @override
  final String signInButtonLabel = 'Sign in';

  @override
  void initWidgetModel() {
    super.initWidgetModel();
  }

  @override
  void onSignInButtonPressed() {
    unawaited(model.signIn().then((_) => widget.onSignedIn()));
  }

  @override
  void dispose() {
    super.dispose();
    emailFieldController.dispose();
  }
}