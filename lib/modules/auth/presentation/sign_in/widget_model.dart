import 'dart:convert';

import 'package:elementary/elementary.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '/app/domain/services/error_handle/service.dart';
import '/app/localizations.dart';
import '/modules/auth/domain/service/service.dart';
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

  @override
  late final WebViewController webViewController = WebViewController()
    ..loadRequest(Uri.parse('https://anime365.ru/'))
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (url) async {
          // TODO: do filtering
          final cookies = await webViewController.runJavaScriptReturningResult(
            'document.cookie',
          );
          final Map<String, String> sessionData = {
            'cookies': cookies.toString(),
          };

          await Hive.initFlutter();
          final box = await Hive.openBox('auth');
          await box.put('session', json.encode(sessionData));
          print('кака ${box.get('session')}');
        },
      ),
    );
}
