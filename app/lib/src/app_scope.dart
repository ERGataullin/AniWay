import 'package:auth/auth.dart';
import 'package:cookie_manager/cookie_manager.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';
import 'package:player/player.dart';

class AppScope extends InheritedWidget {
  AppScope({
    super.key,
    ErrorHandler? errorHandler,
    Network? network,
    Storage? storage,
    CookieManager? cookieManager,
    AuthService? authService,
    MoviesService? moviesService,
    PlayerService? playerService,
    required super.child,
  }) {
    this.errorHandler = errorHandler ?? const DebugPrintErrorHandler();
    this.network = network ??
        HttpNetwork(
          baseUri: kIsWeb
              ? ProxiedUri(
                  proxy: Uri(
                    scheme: 'https',
                    host: 'aniway.fun',
                  ),
                  original: Uri(
                    scheme: 'https',
                    host: 'smotret-anime.online',
                  ),
                )
              : Uri(
                  scheme: 'https',
                  host: 'smotret-anime.online',
                ),
        );
    this.storage = storage ?? const HiveStorage();
    this.cookieManager =
        cookieManager ?? CookieManagerImpl(storage: this.storage);
    this.authService = authService ??
        AuthService(
          repository: AuthRepository(
            remote: Anime365AuthDataSource(
              network: this.network,
              cookieManager: this.cookieManager,
            ),
          ),
          cookieManager: this.cookieManager,
        );
    this.moviesService = moviesService ??
        MoviesService(
          repository: MoviesRepository(
            remote: Anime365MoviesDataSource(
              cookieManager: this.cookieManager,
              network: this.network,
            ),
          ),
        );
    this.playerService = playerService ??
        PlayerService(
          repository: PlayerRepository(
            local: LocalPlayerDataSource(storage: this.storage),
          ),
        );
  }

  late final ErrorHandler errorHandler;

  late final Network network;

  late final Storage storage;

  late final CookieManager cookieManager;

  late final AuthService authService;

  late final MoviesService moviesService;

  late final PlayerService playerService;

  late final List<Initable> dependencies = [
    errorHandler,
    network,
    storage,
    cookieManager,
    authService,
    moviesService,
    playerService,
  ];

  @override
  Widget get child => MultiProvider(
        providers: [
          Provider<ErrorHandler>.value(value: errorHandler),
          Provider<Network>.value(value: network),
          Provider<Storage>.value(value: storage),
          Provider<CookieManager>.value(value: cookieManager),
          Provider<AuthService>.value(value: authService),
          Provider<MoviesService>.value(value: moviesService),
          Provider<PlayerService>.value(value: playerService),
        ],
        child: super.child,
      );

  static AppScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>()!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    if (dependencies.length != oldWidget.dependencies.length) return true;
    for (int i = 0; i < dependencies.length; i++) {
      if (dependencies[i] != oldWidget.dependencies[i]) return true;
    }
    return false;
  }

  Future<void> ensureInitialized() async {
    for (final Initable initable in dependencies) {
      await initable.init();
    }
  }

  Future<void> ensureDisposed() async {
    for (final Initable initable in dependencies) {
      await initable.dispose();
    }
  }
}
