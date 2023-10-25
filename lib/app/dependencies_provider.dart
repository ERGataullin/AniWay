import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/app/domain/services/error_handle/debug_print.dart';
import '/app/domain/services/error_handle/service.dart';
import '/app/domain/services/network/http.dart';
import '/app/domain/services/network/service.dart';
import '/modules/auth/data/repository.dart';
import '/modules/auth/data/sources/local.dart';
import '/modules/auth/domain/service/anime365.dart';
import '/modules/auth/domain/service/service.dart';
import '/modules/movies/data/repository.dart';
import '/modules/movies/domain/service/anime365.dart';
import '/modules/movies/domain/service/service.dart';
import '../modules/movies/data/sources/remote.dart';

class AppDependenciesProvider extends StatelessWidget {
  const AppDependenciesProvider({
    super.key,
    this.errorHandleService,
    this.networkService,
    this.authService,
    this.moviesService,
    required this.child,
  });

  final ErrorHandleService? errorHandleService;
  final NetworkService? networkService;
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
                baseUrl: 'https://shikimori.one',
              ),
        ),
        Provider<AuthService>(
          create: (context) =>
              authService ??
              Anime365AuthService(
                networkService: context.read<NetworkService>(),
                repository: const AuthRepository(
                  local: LocalAuthDataSource(),
                ),
              ),
        ),
        Provider<MoviesService>(
          create: (context) =>
              moviesService ??
              Anime365MoviesService(
                repository: const MoviesRepository(
                  remote: RemoteMoviesDataSource(),
                ),
              ),
        ),
      ],
      child: child,
    );
  }
}
