import 'package:auth/auth.dart';
import 'package:auth/src/presentation/sign_in/model.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:l10n/l10n.dart';

SignInWM signInWMFactory(BuildContext context) => SignInWM(
      SignInModel(
        errorHandler: context.read<ErrorHandler>(),
        service: context.read<AuthService>(),
      ),
    );

abstract interface class ISignInWM implements IWidgetModel {
  ValueListenable<String> get emailLabel;

  ValueListenable<String> get passwordLabel;

  ValueListenable<bool> get obscurePassword;

  ValueListenable<bool> get showLoader;

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
  late final Computed<String> emailLabel = Computed(
    trigger: l10n,
    () => l10n.value.emailLabel,
  );

  @override
  late final Computed<String> passwordLabel = Computed(
    trigger: l10n,
    () => l10n.value.passwordLabel,
  );

  @override
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);

  @override
  final ValueNotifier<bool> showLoader = ValueNotifier(false);

  @override
  late final Computed<String> submitLabel = Computed(
    trigger: l10n,
    () => l10n.value.signInSubmitLabel,
  );

  @override
  final TextEditingController emailController = TextEditingController();

  @override
  final TextEditingController passwordController = TextEditingController();

  @override
  final ImageProvider logo = const AssetImage(
    'assets/images/logo.webp',
    package: 'auth',
  );

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
    emailLabel.dispose();
    passwordLabel.dispose();
    obscurePassword.dispose();
    showLoader.dispose();
    submitLabel.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> _submit() async {
    showLoader.value = true;
    await model.signIn(
      email: emailController.text,
      password: passwordController.text,
    );
    showLoader.value = false;
  }
}
