import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';
import 'package:provider/provider.dart';

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
                  local: StorageAuthDataSource(
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
                  remote: Anime365MoviesDataSource(
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
