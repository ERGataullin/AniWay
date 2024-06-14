import 'package:auth/auth.dart';
import 'package:cookie_manager/cookie_manager.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';

class AppDependenciesProvider extends StatelessWidget {
  const AppDependenciesProvider({
    super.key,
    this.errorHandleService,
    this.networkService,
    this.storageService,
    this.cookieManager,
    this.authService,
    this.moviesService,
    required this.child,
  });

  final ErrorHandler? errorHandleService;
  final Network? networkService;
  final Storage? storageService;
  final CookieManager? cookieManager;
  final AuthService? authService;
  final MoviesService? moviesService;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ErrorHandler>(
          create: (context) =>
              errorHandleService ?? const DebugPrintErrorHandler(),
        ),
        Provider<Network>(
          create: (context) =>
              networkService ??
              HttpNetwork(
                baseUri: kIsWeb
                    ? ProxiedUri(
                        proxy: Uri(
                          scheme: 'https',
                          host: 'aniway.fun',
                        ),
                        original: Uri(
                          scheme: 'https',
                          host: 'smotret-anime.com',
                        ),
                      )
                    : Uri(
                        scheme: 'https',
                        host: 'smotret-anime.com',
                      ),
              ),
        ),
        Provider<Storage>(
          create: (context) => storageService ?? const HiveStorage(),
        ),
        Provider<CookieManager>(
          create: (context) =>
              cookieManager ??
              CookieManagerImpl(
                storage: context.read<Storage>(),
              ),
        ),
        Provider<AuthService>(
          lazy: false,
          create: (context) =>
              authService ??
              Anime365AuthService(
                cookieManager: context.read<CookieManager>(),
                network: context.read<Network>(),
              ),
        ),
        Provider<MoviesService>(
          create: (context) =>
              moviesService ??
              Anime365MoviesService(
                repository: MoviesRepository(
                  remote: Anime365MoviesDataSource(
                    cookieManager: context.read<CookieManager>(),
                    network: context.read<Network>(),
                  ),
                ),
              ),
        ),
      ],
      child: child,
    );
  }
}
