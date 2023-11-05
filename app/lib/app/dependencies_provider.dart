import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

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

  final ErrorHandler? errorHandleService;
  final Network? networkService;
  final Storage? storageService;
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
                baseUri: Uri(
                  scheme: 'https',
                  host: 'anime365.ru',
                ),
              ),
        ),
        Provider<Storage>(
          create: (context) => storageService ?? const HiveStorage(),
        ),
        Provider<AuthService>(
          lazy: false,
          create: (context) =>
              authService ??
              Anime365AuthService(
                network: context.read<Network>(),
                repository: AuthRepository(
                  local: LocalAuthDataSource(
                    storage: context.read<Storage>(),
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
