import 'package:flutter/widgets.dart';
import 'package:flutter_feature_arch/flutter_feature_arch.dart';
import 'package:go_router/go_router.dart';

import '/modules/auth/sign_in/presentation/widget.dart';

class SignInFeature extends Feature<RouteBase> {
  SignInFeature({
    required this.onSignedIn,
  });

  final void Function() onSignedIn;

  String get path => '/sign-in';

  @override
  Set<RouteBase> get routes => <RouteBase>{
        GoRoute(
          path: path,
          builder: (BuildContext context, GoRouterState state) =>
              const SignInWidget(),
        ),
      };
}
