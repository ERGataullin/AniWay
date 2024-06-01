import 'package:auth/auth.dart';
import 'package:auth/src/presentation/sign_in/model.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:l10n/l10n.dart';

SignInWM signInWMFactory(BuildContext context) => SignInWM(
      SignInModel(
        context.read<ErrorHandler>(),
        service: context.read<AuthService>(),
      ),
    );

abstract interface class ISignInWM implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<String> get emailLabel;

  ValueListenable<String> get passwordLabel;

  ValueListenable<bool> get obscurePassword;

  ValueListenable<bool> get showLoader;

  ValueListenable<String> get submitLabel;

  TextEditingController get emailController;

  TextEditingController get passwordController;

  ImageProvider get logo;

  String? onValidateEmail(String? value);

  void onPasswordVisibilityPressed();

  void onPasswordSubmitted(String password);

  void onSubmitPressed();
}

class SignInWM extends WidgetModel<SignInWidget, ISignInModel>
    with L10nWMMixin
    implements ISignInWM {
  SignInWM(super._model);

  @override
  late final ListenableNotifier<String> title = ListenableNotifier(
    l10n,
    () => l10n.value.signInTitle,
  );

  @override
  late final ListenableNotifier<String> emailLabel = ListenableNotifier(
    l10n,
    () => l10n.value.emailLabel,
  );

  @override
  late final ListenableNotifier<String> passwordLabel = ListenableNotifier(
    l10n,
    () => l10n.value.passwordLabel,
  );

  @override
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);

  @override
  final ValueNotifier<bool> showLoader = ValueNotifier(false);

  @override
  late final ListenableNotifier<String> submitLabel = ListenableNotifier(
    l10n,
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
  String? onValidateEmail(String? value) {
    return model.isEmailValid(value) ? null : l10n.value.emailValidationError;
  }

  @override
  void onPasswordVisibilityPressed() {
    obscurePassword.value = !obscurePassword.value;
  }

  @override
  void onPasswordSubmitted(String password) {
    _onSubmit();
  }

  @override
  void onSubmitPressed() {
    _onSubmit();
  }

  Future<void> _onSubmit() async {
    showLoader.value = true;
    await model.signIn(
      email: emailController.text,
      password: passwordController.text,
    );
    widget.onSignedIn();
    showLoader.value = false;
  }

  @override
  void dispose() {
    super.dispose();
    title.dispose();
    emailLabel.dispose();
    passwordLabel.dispose();
    obscurePassword.dispose();
    showLoader.dispose();
    submitLabel.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
