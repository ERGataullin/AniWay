import 'package:app/auth/auth.dart';
import 'package:app/cookie_manager/cookie_manager.dart';
import 'package:app/core/core.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/data/services/anime365.dart';
import 'package:app/player/player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppScope extends InheritedWidget {
  AppScope({
    super.key,
    ErrorHandler? errorHandler,
    NetworkService? networkService,
    StorageService? storageService,
    CookieManager? cookieManager,
    AuthRepository? authService,
    MoviesRepository? moviesRepository,
    PlayerRepository? playerRepository,
    required super.child,
  }) {
    this.errorHandler = errorHandler ?? const DebugPrintErrorHandler();
    this.networkService = networkService ??
        HttpService(
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
    this.storageService = storageService ?? const HiveService();
    this.cookieManager =
        cookieManager ?? CookieManagerImpl(storageService: this.storageService);
    this.authService = authService ??
        AuthRepository(
          authService: AuthServiceAnime365(
            networkService: this.networkService,
            cookieManager: this.cookieManager,
          ),
          cookieManager: this.cookieManager,
        );
    this.moviesRepository = moviesRepository ??
        MoviesRepository(
          moviesService: MoviesServiceAnime365(
            cookieManager: this.cookieManager,
            networkService: this.networkService,
          ),
        );
    this.playerRepository = playerRepository ??
        PlayerRepository(
          playerService:
              LocalPlayerService(storageService: this.storageService),
        );
  }

  late final ErrorHandler errorHandler;

  late final NetworkService networkService;

  late final StorageService storageService;

  late final CookieManager cookieManager;

  late final AuthRepository authService;

  late final MoviesRepository moviesRepository;

  late final PlayerRepository playerRepository;

  late final List<Initable> dependencies = [
    errorHandler,
    networkService,
    storageService,
    cookieManager,
    authService,
    moviesRepository,
    playerRepository,
  ];

  @override
  Widget get child => MultiProvider(
        providers: [
          Provider<ErrorHandler>.value(value: errorHandler),
          Provider<NetworkService>.value(value: networkService),
          Provider<StorageService>.value(value: storageService),
          Provider<CookieManager>.value(value: cookieManager),
          Provider<AuthRepository>.value(value: authService),
          Provider<MoviesRepository>.value(value: moviesRepository),
          Provider<PlayerRepository>.value(value: playerRepository),
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
