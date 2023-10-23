import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import '/app/dependencies_provider.dart';
import '/app/localizations.dart';
import '/app/router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();

  void run() {
    runApp(
      AppDependenciesProvider(
        child: this,
      ),
    );
  }
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    usePathUrlStrategy();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: AppRouter(),
    );
  }
}
