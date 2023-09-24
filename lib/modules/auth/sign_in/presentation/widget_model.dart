import 'package:elementary/elementary.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/modules/auth/module.dart';
import '/modules/auth/sign_in/presentation/model.dart';
import '/modules/auth/sign_in/presentation/widget.dart';

ISignInWidgetModel signInWidgetModelFactory(BuildContext context) =>
    _SignInWidgetModel(SignInModel(
      context.read<ErrorHandler>(),
      onSignedIn: context.read<AuthModule>().signIn.onSignedIn,
    ));

abstract interface class ISignInWidgetModel
    implements IWidgetModel, WidgetModel<SignInWidget, SignInModel> {
  String get title;

  TextEditingController get emailFieldController;

  String get emailFieldLabel;

  String get signInButtonLabel;

  void onSignInButtonPressed();
}

class _SignInWidgetModel extends WidgetModel<SignInWidget, SignInModel>
    implements ISignInWidgetModel {
  _SignInWidgetModel(SignInModel model) : super(model);

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
    model.signIn();
  }

  @override
  void dispose() {
    super.dispose();
    emailFieldController.dispose();
  }
}
