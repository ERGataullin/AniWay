import 'package:auth/auth.dart';
import 'package:auth/src/presentation/sign_in/model.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
    implements ISignInWM {
  SignInWM(super._model);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<String> emailLabel = ValueNotifier('');

  @override
  final ValueNotifier<String> passwordLabel = ValueNotifier('');

  @override
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);

  @override
  final ValueNotifier<bool> showLoader = ValueNotifier(false);

  @override
  final ValueNotifier<String> submitLabel = ValueNotifier('');

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
