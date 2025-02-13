import 'package:app/app/app_scope.dart';
import 'package:app/app/platform_wrapper/platform_wrapper.dart';
import 'package:app/app/router.dart';
import 'package:app/auth/auth.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();

  void run() {
    runApp(AppScope(child: this));
  }
}

class _AppState extends State<App> {
  AppRouter? _router;

  var _initialized = false;

  @override
  void initState() {
    super.initState();
    usePathUrlStrategy();
  }

  @override
  void didChangeDependencies() {
    final AppScope scope = AppScope.of(context);
    scope
      ..networkService.addInterceptor(scope.cookieManager.interceptor)
      ..ensureInitialized().then(
        (_) => setState(() {
          _initialized = true;
        }),
      );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return !_initialized
        ? const SizedBox.shrink()
        : MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: L10n.localizationsDelegates,
          title: 'AniWay',
          theme: Themes.light,
          darkTheme: Themes.dark,
          builder:
              (context, _) => PlatformWrapper(
                child: Router.withConfig(
                  config:
                      _router ??= AppRouter(
                        l10n: context.l10n,
                        signedIn: context.read<AuthRepository>().signedIn,
                      ),
                ),
              ),
        );
  }

  @override
  void dispose() {
    AppScope.of(context).ensureDisposed();
    super.dispose();
  }
}
