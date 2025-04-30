import 'package:app/app/app_scope.dart';
import 'package:app/app/platform_wrapper/platform_wrapper.dart';
import 'package:app/app/router.dart';
import 'package:app/auth/auth.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();

  Future<void> run() async {
    await _setMinWindowSize();
    runApp(AppScope(child: this));
  }

  Future<void> _setMinWindowSize() async {
    if (kIsWeb) return;
    const iPhoneSESize = Size(375, 667);
    WidgetsFlutterBinding.ensureInitialized();
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux ||
          TargetPlatform.macOS ||
          TargetPlatform.windows:
        await windowManager.ensureInitialized();
        WindowManager.instance.setMinimumSize(iPhoneSESize);
      case TargetPlatform.android ||
          TargetPlatform.fuchsia ||
          TargetPlatform.iOS:
    }
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
        : Builder(
          builder: (context) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              supportedLocales: L10n.supportedLocales,
              localizationsDelegates: L10n.localizationsDelegates,
              title: 'AniWay',
              theme: Themes.light(context),
              darkTheme: Themes.dark(context),
              builder:
                  (context, _) => PlatformWrapper(
                    child: Router.withConfig(
                      config:
                          _router ??= AppRouter(
                            signedIn: context.read<AuthRepository>().signedIn,
                          ),
                    ),
                  ),
            );
          },
        );
  }

  @override
  void dispose() {
    AppScope.of(context).ensureDisposed();
    super.dispose();
  }
}
