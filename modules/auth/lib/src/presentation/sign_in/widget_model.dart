import 'package:auth/auth.dart';
import 'package:auth/src/presentation/sign_in/model.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

SignInWidgetModel signInWidgetModelFactory(BuildContext context) =>
    SignInWidgetModel(
      SignInModel(
        context.read<ErrorHandler>(),
        service: context.read<AuthService>(),
        webResourcesBaseUri: context.read<Network>().baseUri,
      ),
    );

abstract interface class ISignInWidgetModel implements IWidgetModel {
  WebViewController get webViewController;
}

class SignInWidgetModel extends WidgetModel<SignInWidget, ISignInModel>
    implements ISignInWidgetModel {
  SignInWidgetModel(super._model);

  @override
  WebViewController get webViewController => model.webViewController;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model.signedIn.addListener(_onSignedInChanged);
  }

  @override
  void dispose() {
    super.dispose();
    model.signedIn.removeListener(_onSignedInChanged);
  }

  void _onSignedInChanged() {
    if (model.signedIn.value) {
      widget.onSignedIn();
    }
  }
}
