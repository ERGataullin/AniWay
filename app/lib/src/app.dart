import 'package:app/src/dependencies_provider.dart';
import 'package:app/src/router.dart';
import 'package:app/src/theme.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:movies/movies.dart';
import 'package:player/player.dart';
import 'package:root_menu/root_menu.dart';

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

  late final AppRouter _router = AppRouter(
    videoPlayerTheme: _theme.videoPlayer,
    signedIn: context.read<AuthService>().signedIn,
  );

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    usePathUrlStrategy();
    _initializeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? MaterialApp.router(
            debugShowCheckedModeBanner: false,
            supportedLocales: [
              AuthLocalizations.supportedLocales.toSet(),
              RootMenuLocalizations.supportedLocales.toSet(),
              MoviesLocalizations.supportedLocales.toSet(),
              PlayerLocalizations.supportedLocales.toSet(),
            ]
                .reduce((value, element) => value.intersection(element))
                .toList(growable: false),
            localizationsDelegates: const [
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              AuthLocalizations.delegate,
              RootMenuLocalizations.delegate,
              MoviesLocalizations.delegate,
              PlayerLocalizations.delegate,
            ],
            theme: _theme.light,
            darkTheme: _theme.dark,
            routerConfig: _router,
          )
        : const SizedBox.shrink();
  }

  Future<void> _initializeDependencies() async {
    await context.read<Storage>().initialize();
    if (!mounted) {
      return;
    }
    await context.read<AuthService>().initialize();

    setState(() {
      _initialized = true;
    });
  }
}
