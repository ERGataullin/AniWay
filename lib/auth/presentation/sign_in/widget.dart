import 'package:app/auth/presentation/sign_in/wm.dart';
import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:flutter/material.dart';

extension SignInContext on BuildContext {
  ISignInWM get wm => read<ISignInWM>();
}

class SignInWidget extends ElementaryWidget<ISignInWM> {
  const SignInWidget({
    super.key,
    WidgetModelFactory wmFactory = signInWMFactory,
  }) : super(wmFactory);

  @override
  Widget build(ISignInWM wm) {
    return Provider<ISignInWM>.value(
      value: wm,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: AutofillGroup(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 720,
                  ),
                  child: const SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 16),
                        _Logo(),
                        SizedBox(height: 32),
                        _EmailField(),
                        SizedBox(height: 16),
                        _PasswordField(),
                        SizedBox(height: 32),
                        _SubmitButton(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 256,
      child: Logo(),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: context.wm.emailController,
      autofocus: true,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [
        AutofillHints.username,
        AutofillHints.email,
      ],
      validator: context.wm.handleValidateEmail,
      decoration: InputDecoration(
        label: Text(context.l10n.emailLabel),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.obscurePassword,
      builder: (context, __) => TextFormField(
        controller: context.wm.passwordController,
        autofocus: true,
        obscureText: context.wm.obscurePassword.value,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.visiblePassword,
        autofillHints: const [AutofillHints.password],
        onFieldSubmitted: context.wm.handlePasswordSubmitted,
        decoration: InputDecoration(
          label: Text(context.l10n.passwordLabel),
          suffixIcon: IconButton(
            onPressed: context.wm.handlePasswordVisibilityPressed,
            isSelected: !context.wm.obscurePassword.value,
            icon: const Icon(Icons.visibility_off_outlined),
            selectedIcon: const Icon(Icons.visibility_outlined),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: context.wm.handleSubmitPressed,
      child: ListenableBuilder(
        listenable: context.wm.loading,
        builder: (context, __) => AnimatedSwitcher(
          switchInCurve: Easing.standard,
          switchOutCurve: Easing.standard.flipped,
          duration: Durations.medium2,
          child: context.wm.loading.value
              ? SizedBox.square(
                  dimension: IconTheme.of(context).size,
                  child: const CircularProgressIndicator.adaptive(),
                )
              : ValueListenableBuilder(
                  valueListenable: context.wm.submitLabel,
                  builder: (context, label, ___) => Text(label),
                ),
        ),
      ),
    );
  }
}
