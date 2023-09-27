import 'package:flutter/services.dart';
import 'package:flutter_feature_arch/flutter_feature_arch.dart';
import 'package:go_router/go_router.dart';

import '/modules/auth/sign_in/feature.dart';

class AuthModule extends Module<RouteBase> {
  AuthModule({
    required VoidCallback onSignedIn,
  }) : signIn = SignInFeature(
          onSignedIn: onSignedIn,
        );

  final SignInFeature signIn;

  @override
  Set<Feature<RouteBase>> get features => <Feature<RouteBase>>{
        signIn,
      };
}
