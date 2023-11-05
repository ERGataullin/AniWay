import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:menu/menu.dart';
import 'package:movies/movies.dart';

import '/app/dependencies_provider.dart';
import '/app/localizations.dart';
import '/app/router.dart';
import '/app/theme.dart';

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
  final AppTheme _theme = AppTheme();

  @override
  void initState() {
    super.initState();
    usePathUrlStrategy();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        AppLocalizations.delegate,
        AuthLocalizations.delegate,
        MenuLocalizations.delegate,
        MoviesLocalizations.delegate,
      ],
      theme: _theme.light,
      darkTheme: _theme.dark,
      routerConfig: AppRouter(),
    );
  }
}
