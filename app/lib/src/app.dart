import 'package:app/src/dependencies_provider.dart';
import 'package:app/src/router.dart';
import 'package:app/src/theme.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:l10n/l10n.dart';

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

  AppRouter? _router;

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
        ? MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: L10n.supportedLocales,
            localizationsDelegates: L10n.localizationsDelegates,
            title: 'AniWay',
            theme: _theme.light,
            darkTheme: _theme.dark,
            builder: (context, __) {
              _router ??= AppRouter(
                l10n: context.l10n,
                videoPlayerTheme: _theme.videoPlayer,
                signedIn: context.read<AuthService>().signedIn,
              );
              return Router.withConfig(config: _router!);
            },
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
