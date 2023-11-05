import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/app/domain/services/error_handle/debug_print.dart';
import '/app/domain/services/error_handle/service.dart';
import '/app/domain/services/network/http.dart';
import '/app/domain/services/storage/hive.dart';
import '/modules/auth/data/repository.dart';
import '/modules/auth/data/sources/local.dart';
import '/modules/auth/domain/service/anime365.dart';
import '/modules/auth/domain/service/service.dart';
import '/modules/movies/data/repository.dart';
import '/modules/movies/data/sources/remote.dart';
import '/modules/movies/domain/service/anime365.dart';
import '/modules/movies/domain/service/service.dart';

class AppDependenciesProvider extends StatelessWidget {
  const AppDependenciesProvider({
    super.key,
    this.errorHandleService,
    this.networkService,
    this.storageService,
    this.authService,
    this.moviesService,
    required this.child,
  });

  final ErrorHandleService? errorHandleService;
  final NetworkService? networkService;
  final StorageService? storageService;
  final AuthService? authService;
  final MoviesService? moviesService;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ErrorHandleService>(
          create: (context) =>
              errorHandleService ?? DebugPrintErrorHandleService(),
        ),
        Provider<NetworkService>(
          create: (context) =>
              networkService ??
              HttpNetworkService(
                baseUri: Uri(
                  scheme: 'https',
                  host: 'anime365.ru',
                ),
              ),
        ),
        Provider<StorageService>(
          create: (context) => storageService ?? const HiveStorageService(),
        ),
        Provider<AuthService>(
          lazy: false,
          create: (context) =>
              authService ??
              Anime365AuthService(
                networkService: context.read<NetworkService>(),
                repository: AuthRepository(
                  local: LocalAuthDataSource(
                    storageService: context.read<StorageService>(),
                  ),
                ),
              ),
        ),
        Provider<MoviesService>(
          create: (context) =>
              moviesService ??
              Anime365MoviesService(
                repository: MoviesRepository(
                  remote: RemoteMoviesDataSource(
                    networkService: context.read<NetworkService>(),
                  ),
                ),
              ),
        ),
      ],
      child: child,
    );
  }
}
