import 'package:auth/src/presentation/sign_in/widget_model.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SignInWidget extends ElementaryWidget<ISignInWidgetModel> {
  const SignInWidget({
    super.key,
    required this.onSignedIn,
    WidgetModelFactory wmFactory = signInWidgetModelFactory,
  }) : super(wmFactory);

  final VoidCallback onSignedIn;

  @override
  Widget build(ISignInWidgetModel wm) {
    return Scaffold(
      body: WebViewWidget(
        controller: wm.webViewController,
      ),
    );
  }
}
