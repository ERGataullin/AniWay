import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';

import '/modules/auth/features/sign_in/widget_model.dart';

class SignInWidget extends ElementaryWidget<ISignInWidgetModel> {
  const SignInWidget({
    super.key,
    WidgetModelFactory wmFactory = signInWidgetModelFactory,
    required this.onSignedIn,
  }) : super(wmFactory);

  final VoidCallback onSignedIn;

  @override
  Widget build(ISignInWidgetModel wm) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wm.title),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: wm.emailFieldController,
            decoration: InputDecoration(
              label: Text(wm.emailFieldLabel),
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: wm.onSignInButtonPressed,
            child: Text(wm.signInButtonLabel),
          ),
        ],
      ),
    );
  }
}
