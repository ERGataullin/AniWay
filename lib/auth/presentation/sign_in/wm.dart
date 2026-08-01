import 'package:app/auth/auth.dart';
import 'package:app/auth/presentation/sign_in/model.dart';
import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

SignInWM signInWMFactory(BuildContext context) => SignInWM(
  SignInModel(
    errorHandler: context.read<ErrorHandler>(),
    repository: context.read<AuthRepository>(),
  ),
);

abstract interface class ISignInWM implements IWidgetModel {
  ValueListenable<bool> get obscurePassword;

  ValueListenable<bool> get loading;

  ValueListenable<String> get submitLabel;

  TextEditingController get emailController;

  TextEditingController get passwordController;

  ImageProvider get logo;

  String? handleValidateEmail(String? value);

  void handlePasswordVisibilityPressed();

  void handlePasswordSubmitted(String password);

  void handleSubmitPressed();
}

class SignInWM extends WidgetModel<SignInWidget, ISignInModel>
    with L10nWMMixin
    implements ISignInWM {
  SignInWM(super._model);

  @override
  final ValueNotifier<bool> obscurePassword = .new(true);

  @override
  final ValueNotifier<bool> loading = .new(false);

  @override
  late final Computed<String> submitLabel = .new(
    trigger: l10n,
    () => l10n.value.signInSubmitLabel,
  );

  @override
  final emailController = TextEditingController();

  @override
  final passwordController = TextEditingController();

  @override
  final ImageProvider logo = const AssetImage('assets/images/logo.webp');

  @override
  String? handleValidateEmail(String? value) {
    return model.isEmailValid(value) ? null : l10n.value.emailValidationError;
  }

  @override
  void handlePasswordVisibilityPressed() {
    obscurePassword.value = !obscurePassword.value;
  }

  @override
  void handlePasswordSubmitted(String password) {
    _submit();
  }

  @override
  void handleSubmitPressed() {
    _submit();
  }

  @override
  void dispose() {
    super.dispose();
    obscurePassword.dispose();
    loading.dispose();
    submitLabel.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> _submit() async {
    loading.value = true;
    await model.signIn(
      email: emailController.text,
      password: passwordController.text,
    );
    loading.value = false;
  }
}
