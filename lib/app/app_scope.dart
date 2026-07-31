import 'package:app/auth/auth.dart';
import 'package:app/auth/data/services/mock.dart';
import 'package:app/cookie_manager/cookie_manager.dart';
import 'package:app/core/core.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/data/services/anime365.dart';
import 'package:app/movies/data/services/mock.dart';
import 'package:app/player/player.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

class AppScope extends InheritedWidget {
  AppScope({
    super.key,
    ErrorHandler? errorHandler,
    NetworkService? networkService,
    StorageService? storageService,
    CookieManager? cookieManager,
    AuthRepository? authRepository,
    MoviesRepository? moviesRepository,
    PlayerRepository? playerRepository,
    required super.child,
  }) {
    const useMocks = bool.fromEnvironment('USE_MOCKS');
    final serverUri = Uri(scheme: 'https', host: 'smotret-anime.app');
    const Uri? proxyUri = null;
    // TODO(Edgar): Вернуть после поднятия прокси.
    // final Uri? proxyUri = !kIsWeb || useMocks
    //     ? null
    //     : .new(scheme: 'https', host: 'aniway.su');

    this.errorHandler = errorHandler ?? const DebugPrintErrorHandler();
    this.networkService =
        networkService ??
        HttpService(
          userAgent: 'AniWay',
          baseUri: proxyUri == null
              ? serverUri
              : ProxiedUri(proxy: proxyUri, original: serverUri),
        );
    this.storageService = storageService ?? const HiveService();
    this.cookieManager =
        cookieManager ??
        CookieManager(
          useCustomCookieHeader: proxyUri != null,
          storageService: this.storageService,
        );
    this.authRepository =
        authRepository ??
        AuthRepository(
          authService: useMocks
              ? AuthServiceMock(cookieManager: this.cookieManager)
              : AuthServiceAnime365(
                  networkService: this.networkService,
                  cookieManager: this.cookieManager,
                ),
          cookieManager: this.cookieManager,
        );
    this.moviesRepository =
        moviesRepository ??
        MoviesRepository(
          moviesService: useMocks
              ? const MoviesServiceMock()
              : MoviesServiceAnime365(
                  cookieManager: this.cookieManager,
                  networkService: this.networkService,
                ),
        );
    this.playerRepository =
        playerRepository ??
        PlayerRepository(
          playerService: LocalPlayerService(
            storageService: this.storageService,
          ),
        );
  }

  late final ErrorHandler errorHandler;

  late final NetworkService networkService;

  late final StorageService storageService;

  late final CookieManager cookieManager;

  late final AuthRepository authRepository;

  late final MoviesRepository moviesRepository;

  late final PlayerRepository playerRepository;

  late final List<Initable> dependencies = [
    errorHandler,
    networkService,
    storageService,
    cookieManager,
    authRepository,
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
      Provider<AuthRepository>.value(value: authRepository),
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
    return !const DeepCollectionEquality().equals(
      dependencies,
      oldWidget.dependencies,
    );
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
