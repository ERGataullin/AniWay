import 'package:app/src/dependencies_provider.dart';
import 'package:app/src/router.dart';
import 'package:auth/auth.dart';
import 'package:cookie_manager/cookie_manager.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:l10n/l10n.dart';
import 'package:theme/theme.dart';

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
  AppRouter? _router;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: L10n.supportedLocales,
            localizationsDelegates: L10n.localizationsDelegates,
            title: 'AniWay',
            theme: Themes.light,
            darkTheme: Themes.dark,
            builder: (context, __) {
              _router ??= AppRouter(
                l10n: context.l10n,
                signedIn: context.read<AuthService>().signedIn,
              );
              return Router.withConfig(config: _router!);
            },
          )
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
    context.read<CookieManager>().dispose();
    super.dispose();
  }

  Future<void> _init() async {
    usePathUrlStrategy();

    await context.read<Storage>().initialize();

    if (!mounted) return;
    final CookieManager cookieManager = context.read<CookieManager>();
    context.read<Network>().addInterceptor(cookieManager.interceptor);
    await cookieManager.init();

    if (!mounted) return;
    await context.read<AuthService>().init();

    setState(() {
      _initialized = true;
    });
  }
}
