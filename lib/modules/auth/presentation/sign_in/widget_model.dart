import 'dart:async';
import 'dart:io';

import 'package:elementary/elementary.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '/app/domain/services/error_handle/service.dart';
import '/modules/auth/domain/service.dart';
import '/modules/auth/presentation/sign_in/model.dart';
import '/modules/auth/presentation/sign_in/widget.dart';

SignInWidgetModel signInWidgetModelFactory(BuildContext context) =>
    SignInWidgetModel(
      SignInModel(
        context.read<ErrorHandleService>(),
        service: context.read<AuthService>(),
      ),
    );

abstract interface class ISignInWidgetModel implements IWidgetModel {
  WebViewController get webViewController;
}

class SignInWidgetModel extends WidgetModel<SignInWidget, ISignInModel>
    implements ISignInWidgetModel {
  SignInWidgetModel(super._model);

  final Box<String> sessionBox = Hive.box<String>('session');

  @override
  late final WebViewController webViewController = WebViewController()
    ..loadRequest(Uri.parse('https://anime365.ru/'))
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) async {

        },
      ),
    );
}
