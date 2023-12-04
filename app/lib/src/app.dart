import 'package:app/src/dependencies_provider.dart';
import 'package:app/src/router.dart';
import 'package:app/src/theme.dart';
import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:menu/menu.dart';
import 'package:movies/movies.dart';
import 'package:player/player.dart';

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
      supportedLocales: [
        AuthLocalizations.supportedLocales.toSet(),
        MenuLocalizations.supportedLocales.toSet(),
        MoviesLocalizations.supportedLocales.toSet(),
        PlayerLocalizations.supportedLocales.toSet(),
      ]
          .reduce((value, element) => value.intersection(element))
          .toList(growable: false),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        AuthLocalizations.delegate,
        MenuLocalizations.delegate,
        MoviesLocalizations.delegate,
        PlayerLocalizations.delegate,
      ],
      theme: _theme.light,
      darkTheme: _theme.dark,
      routerConfig: AppRouter(),
    );
  }
}
