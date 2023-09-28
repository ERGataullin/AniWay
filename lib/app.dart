import 'package:flutter/material.dart';
import 'package:flutter_feature_arch/flutter_feature_arch.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/app_dependencies.dart';
import '/modules/auth/module.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Modular<RouteBase>(
      modules: context.read<Set<Module<RouteBase>>>(),
      child: Builder(
        builder: (BuildContext context) => MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: context.read<AuthModule>().signIn.path,
            routes:
                Modular.of<RouteBase>(context).routes.toList(growable: false),
          ),
        ),
      ),
    );
  }

  void run({
    Set<Provider<dynamic>> dependencyOverrides = const <Provider<dynamic>>{},
  }) {
    runApp(
      AppDependenciesProvider(
        overrides: dependencyOverrides,
        child: this,
      ),
    );
  }
}
