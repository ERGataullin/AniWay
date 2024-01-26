import 'dart:core';
import 'dart:io';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

abstract interface class ISignInModel implements ElementaryModel {
  ValueListenable<bool> get signedIn;

  WebViewController get webViewController;
}

class SignInModel extends ElementaryModel implements ISignInModel {
  SignInModel(
    ErrorHandler errorHandler, {
    required Uri webResourcesBaseUri,
    required AuthService service,
  })  : _signInUri = webResourcesBaseUri.resolve('/users/login'),
        _signedInUris = {
          webResourcesBaseUri,
          webResourcesBaseUri.resolve('/users/profile'),
        },
        _service = service,
        super(errorHandler: errorHandler);

  @override
  final ValueNotifier<bool> signedIn = ValueNotifier(false);

  @override
  final WebViewController webViewController = WebViewController();

  final AuthService _service;

  final WebviewCookieManager _cookieManager = WebviewCookieManager();

  final Uri _signInUri;

  final Set<Uri> _signedInUris;

  @override
  void init() {
    webViewController
      ..loadRequest(_signInUri)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: _onUrlChange,
        ),
      );
  }

  @override
  void dispose() {
    super.dispose();
    signedIn.dispose();
  }

  Future<void> _onUrlChange(UrlChange urlChange) async {
    if (signedIn.value || urlChange.url == null) {
      return;
    }

    final Uri uri = Uri.parse(urlChange.url!);

    if (_signedInUris.contains(uri)) {
      return;
    }

    final List<Cookie> cookies =
        await _cookieManager.getCookies(_signInUri.toString());
    final String cookieString =
        cookies.map((cookie) => '${cookie.name}=${cookie.value}').join(';');
    _service.signIn(cookieString);

    signedIn.value = true;
  }
}
