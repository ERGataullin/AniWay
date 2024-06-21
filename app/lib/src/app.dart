import 'package:app/src/app_scope.dart';
import 'package:app/src/router.dart';
import 'package:app/src/web_media_query.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
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
      AppScope(
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
    usePathUrlStrategy();
  }

  @override
  void didChangeDependencies() {
    final AppScope scope = AppScope.of(context);
    scope
      ..network.addInterceptor(scope.cookieManager.interceptor)
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
            builder: (context, __) {
              final Widget router = Router.withConfig(
                config: _router ??= AppRouter(
                  l10n: context.l10n,
                  signedIn: context.read<AuthService>().signedIn,
                ),
              );

              return kIsWeb ? WebMediaQuery(child: router) : router;
            },
          );
  }

  @override
  void dispose() {
    AppScope.of(context).ensureDisposed();
    super.dispose();
  }
}
