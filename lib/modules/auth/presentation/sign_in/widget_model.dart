import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/app/domain/services/error_handle/service.dart';
import '/app/localizations.dart';
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

  TextEditingController get passwordFieldController;

  String get passwordFieldLabel;

  String get signInButtonLabel;

  void onSignInButtonPressed();
}

class SignInWidgetModel extends WidgetModel<SignInWidget, ISignInModel>
    implements ISignInWidgetModel {
  SignInWidgetModel(super._model);

  @override
  final TextEditingController emailFieldController = TextEditingController();

  @override
  final TextEditingController passwordFieldController = TextEditingController();

  @override
  String get title => context.localizations.authSignInTitle;

  @override
  String get emailFieldLabel => context.localizations.authSignInEmailLabel;

  @override
  String get passwordFieldLabel =>
      context.localizations.authSignInPasswordLabel;

  @override
  String get signInButtonLabel => context.localizations.authSignInSubmitLabel;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
  }

  @override
  void onSignInButtonPressed() {
    unawaited(
      model
          .signIn(emailFieldController.text, passwordFieldController.text)
          .then(
            (_) => widget.onSignedIn(),
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    emailFieldController.dispose();
  }
}
