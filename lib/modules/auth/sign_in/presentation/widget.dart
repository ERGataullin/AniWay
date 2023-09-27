import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';

import '/modules/auth/sign_in/presentation/widget_model.dart';

class SignInWidget extends ElementaryWidget<ISignInWidgetModel> {
  const SignInWidget({
    super.key,
    WidgetModelFactory wmFactory = signInWidgetModelFactory,
  }) : super(wmFactory);

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
