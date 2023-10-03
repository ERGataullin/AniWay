import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/app/dependencies_provider.dart';
import '/app/router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter(),
    );
  }

  void run({
    Set<Provider<dynamic>> dependencyOverrides = const {},
  }) {
    runApp(
      AppDependenciesProvider(
        overrides: dependencyOverrides,
        child: this,
      ),
    );
  }
}
