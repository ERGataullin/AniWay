import 'package:app/auth/presentation/sign_in/wm.dart';
import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:flutter/material.dart';

extension _SignInContext on BuildContext {
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
      builder: (context, _) {
        final double margin = Breakpoint.activeBreakpointOf(context).margin;
        return Scaffold(
          body: Padding(
            padding: .symmetric(horizontal: margin),
            child: Form(
              autovalidateMode: .onUserInteraction,
              child: AutofillGroup(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const .new(maxWidth: 720),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .stretch,
                        children: [
                          SizedBox(height: margin),
                          const _Logo(),
                          const SizedBox(height: 32),
                          const _EmailField(),
                          const SizedBox(height: 16),
                          const _PasswordField(),
                          const SizedBox(height: 32),
                          const _SubmitButton(),
                          SizedBox(height: margin),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 256, child: FittedBox(child: Logo.short()));
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: context.wm.emailController,
      autofocus: true,
      textInputAction: .next,
      keyboardType: .emailAddress,
      autofillHints: const [AutofillHints.username, AutofillHints.email],
      validator: context.wm.handleValidateEmail,
      decoration: .new(label: Text(context.l10n.emailLabel)),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.obscurePassword,
      builder: (context, _) => TextFormField(
        controller: context.wm.passwordController,
        autofocus: true,
        obscureText: context.wm.obscurePassword.value,
        textInputAction: .done,
        keyboardType: .visiblePassword,
        autofillHints: const [AutofillHints.password],
        onFieldSubmitted: context.wm.handlePasswordSubmitted,
        decoration: .new(
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
        builder: (context, _) {
          final IconThemeData iconTheme = IconTheme.of(context);
          return AnimatedSwitcher(
            switchInCurve: Easing.standard,
            switchOutCurve: Easing.standard.flipped,
            duration: Durations.medium2,
            child: context.wm.loading.value
                ? CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(iconTheme.color!),
                    constraints: .tight(.square(iconTheme.size!)),
                  )
                : ValueListenableBuilder(
                    valueListenable: context.wm.submitLabel,
                    builder: (context, label, _) => Text(label),
                  ),
          );
        },
      ),
    );
  }
}
