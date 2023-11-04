import 'package:elementary/elementary.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '/app/domain/services/error_handle/service.dart';
import '/app/domain/services/network/service.dart';
import '/modules/auth/domain/service/service.dart';
import '/modules/auth/presentation/sign_in/model.dart';
import '/modules/auth/presentation/sign_in/widget.dart';

SignInWidgetModel signInWidgetModelFactory(BuildContext context) =>
    SignInWidgetModel(
      SignInModel(
        context.read<ErrorHandleService>(),
        service: context.read<AuthService>(),
      ),
      webResourcesBaseUri: context.read<NetworkService>().baseUri,
    );

abstract interface class ISignInWidgetModel implements IWidgetModel {
  WebViewController get webViewController;
}

class SignInWidgetModel extends WidgetModel<SignInWidget, ISignInModel>
    implements ISignInWidgetModel {
  SignInWidgetModel(
    super._model, {
    required Uri webResourcesBaseUri,
  }) : _webResourcesBaseUri = webResourcesBaseUri;

  final Uri _webResourcesBaseUri;

  final WebviewCookieManager _cookieManager = WebviewCookieManager();

  bool _signedIn = false;

  @override
  late final WebViewController webViewController = WebViewController()
    ..loadRequest(_webResourcesBaseUri)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onUrlChange: (urlChange) {
          if (_signedIn) {
            return;
          }
          if (urlChange.url != '$_webResourcesBaseUri/' &&
              urlChange.url !=
                  _webResourcesBaseUri.resolve('/users/profile').toString()) {
            return;
          }

          _signedIn = true;
          _cookieManager
              .getCookies(_webResourcesBaseUri.toString())
              .then(
                (cookies) => model.signIn(
                  cookies
                      .map((cookie) => '${cookie.name}=${cookie.value}')
                      .join(';'),
                ),
              )
              .then((_) => widget.onSignedIn());
        },
      ),
    );
}
