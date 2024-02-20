import 'package:auth/src/presentation/sign_in/widget_model.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

extension SignInContext on BuildContext {
  ISignInWidgetModel get wm => read<ISignInWidgetModel>();
}

class SignInWidget extends ElementaryWidget<ISignInWidgetModel> {
  const SignInWidget({
    super.key,
    required this.onSignedIn,
    WidgetModelFactory wmFactory = signInWidgetModelFactory,
  }) : super(wmFactory);

  final VoidCallback onSignedIn;

  @override
  Widget build(ISignInWidgetModel wm) {
    return Provider<ISignInWidgetModel>.value(
      value: wm,
      child: Scaffold(
        appBar: AppBar(
          title: const _Title(),
        ),
        body: Form(
          key: wm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: const Padding(
            padding: EdgeInsets.all(16),
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
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _SubmitButton(),
                  ),
                ),
              ],
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
    return Image.asset(
      'assets/images/logo.webp',
      package: 'auth',
      height: 256,
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
    return ValueListenableBuilder(
      valueListenable: context.wm.passwordLabel,
      builder: (context, label, ___) => ValueListenableBuilder(
        valueListenable: context.wm.obscurePassword,
        builder: (context, obscure, ___) => TextFormField(
          controller: context.wm.passwordController,
          autofocus: true,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            label: Text(label),
            suffixIcon: IconButton(
              onPressed: context.wm.onPasswordVisibilityPressed,
              isSelected: !obscure,
              icon: const Icon(Icons.visibility_off_outlined),
              selectedIcon: const Icon(Icons.visibility_outlined),
            ),
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
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: context.wm.onSubmitPressed,
        child: ValueListenableBuilder(
          valueListenable: context.wm.submitLabel,
          builder: (context, label, ___) => Text(label),
        ),
      ),
    );
  }
}
