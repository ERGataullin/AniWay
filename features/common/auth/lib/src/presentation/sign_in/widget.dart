import 'package:auth/src/presentation/sign_in/wm.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

extension SignInContext on BuildContext {
  ISignInWM get wm => read<ISignInWM>();
}

class SignInWidget extends ElementaryWidget<ISignInWM> {
  const SignInWidget({
    super.key,
    required this.onSignedIn,
    WidgetModelFactory wmFactory = signInWMFactory,
  }) : super(wmFactory);

  final VoidCallback onSignedIn;

  @override
  Widget build(ISignInWM wm) {
    return Provider<ISignInWM>.value(
      value: wm,
      child: Scaffold(
        appBar: AppBar(
          title: const _Title(),
        ),
        body: const Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: AutofillGroup(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Logo(),
                  ),
                  SizedBox(height: 16),
                  _EmailField(),
                  SizedBox(height: 16),
                  _PasswordField(),
                  SizedBox(height: 16),
                  _SubmitButton(),
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.title,
      builder: (context, title, ___) => Text(title),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Image(
      height: 256,
      image: context.wm.logo,
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.emailLabel,
      builder: (context, label, ___) => TextFormField(
        controller: context.wm.emailController,
        autofocus: true,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [
          AutofillHints.username,
          AutofillHints.email,
        ],
        validator: context.wm.onValidateEmail,
        decoration: InputDecoration(
          label: Text(label),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        context.wm.passwordLabel,
        context.wm.obscurePassword,
      ]),
      builder: (context, __) => TextFormField(
        controller: context.wm.passwordController,
        autofocus: true,
        obscureText: context.wm.obscurePassword.value,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.visiblePassword,
        autofillHints: const [AutofillHints.password],
        onFieldSubmitted: context.wm.onPasswordSubmitted,
        decoration: InputDecoration(
          label: Text(context.wm.passwordLabel.value),
          suffixIcon: IconButton(
            onPressed: context.wm.onPasswordVisibilityPressed,
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
      onPressed: context.wm.onSubmitPressed,
      child: ListenableBuilder(
        listenable: context.wm.showLoader,
        builder: (context, __) => AnimatedSwitcher(
          switchInCurve: Easing.standard,
          switchOutCurve: Easing.standard.flipped,
          duration: Durations.medium2,
          child: context.wm.showLoader.value
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
