import 'package:auth/auth.dart';
import 'package:auth/src/presentation/sign_in/model.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

SignInWidgetModel signInWidgetModelFactory(BuildContext context) =>
    SignInWidgetModel(
      SignInModel(
        context.read<ErrorHandler>(),
        service: context.read<AuthService>(),
      ),
    );

abstract interface class ISignInWidgetModel implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<String> get emailLabel;

  ValueListenable<String> get passwordLabel;

  ValueListenable<bool> get obscurePassword;

  ValueListenable<String> get submitLabel;

  TextEditingController get emailController;

  TextEditingController get passwordController;

  Key? get formKey;

  String? onValidateEmail(String? value);

  void onPasswordVisibilityPressed();

  void onSubmitPressed();
}

class SignInWidgetModel extends WidgetModel<SignInWidget, ISignInModel>
    implements ISignInWidgetModel {
  SignInWidgetModel(super._model);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<String> emailLabel = ValueNotifier('');

  @override
  final ValueNotifier<String> passwordLabel = ValueNotifier('');

  @override
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);

  @override
  final ValueNotifier<String> submitLabel = ValueNotifier('');

  @override
  final TextEditingController emailController = TextEditingController();

  @override
  final TextEditingController passwordController = TextEditingController();

  @override
  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initWidgetModel() {
    super.initWidgetModel();
  }

  @override
  void didChangeDependencies() {
    title.value = context.localizations.signInTitle;
    emailLabel.value = context.localizations.signInEmailLabel;
    passwordLabel.value = context.localizations.signInPasswordLabel;
    submitLabel.value = context.localizations.singInSubmitLabel;
  }

  @override
  String? onValidateEmail(String? value) {
    return model.isEmailValid(value)
        ? null
        : context.localizations.signInEmailInvalidError;
  }

  @override
  void onPasswordVisibilityPressed() {
    obscurePassword.value = !obscurePassword.value;
  }

  @override
  Future<void> onSubmitPressed() async {
    await model.signIn(
      email: emailController.text,
      password: passwordController.text,
    );
    widget.onSignedIn();
  }

  @override
  void dispose() {
    super.dispose();
    title.dispose();
    emailLabel.dispose();
    passwordLabel.dispose();
    obscurePassword.dispose();
    submitLabel.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
