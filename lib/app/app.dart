import 'package:app/app/app_scope.dart';
import 'package:app/app/platform_wrapper/platform_wrapper.dart';
import 'package:app/app/router.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/theme/theme.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
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
  Future<void> didChangeDependencies() async {
    final AppScope scope = AppScope.of(context);
    scope.networkService.addInterceptor(scope.cookieManager.interceptor);
    await scope.ensureInitialized();
    setState(() {
      _initialized = true;
      _router ??= AppRouter(signedIn: scope.authRepository.signedIn);
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,
      title: 'AniWay',
      theme: Themes.light(context),
      darkTheme: Themes.dark(context),
      routerConfig: _router,
      builder: (context, router) {
        Widget child = router!;
        if (kDebugMode) {
          final Orientation orientation = MediaQuery.orientationOf(context);
          final bool useDeviceFrame = switch (orientation) {
            Orientation.portrait => Breakpoints.small.isActive(context),
            Orientation.landscape => Breakpoints.medium.isActive(context),
          };
          if (useDeviceFrame) {
            child = DeviceFrame(
              device: Devices.ios.iPhone13Mini,
              orientation: orientation,
              screen: child,
            );
          }
        }
        return PlatformWrapper(child: child);
      },
    );
  }

  @override
  void dispose() {
    AppScope.of(context).ensureDisposed();
    super.dispose();
  }
}
